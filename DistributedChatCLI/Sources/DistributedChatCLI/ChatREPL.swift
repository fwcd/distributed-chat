import Foundation
import LineNoise
import DistributedChat

fileprivate let globalChannelName = "global"

class ChatREPL {
    private let transport: ChatTransport
    private let controller: ChatController
    private let network: Network = Network()

    private let commandPrefix: String
    private var commands: [String: () -> Void]!
    
    init(transport: ChatTransport, name: String, commandPrefix: String = ".") {
        self.transport = transport
        self.commandPrefix = commandPrefix

        controller = ChatController(transport: transport)
        controller.update(name: name)

        controller.onAddChatMessage { [unowned self] msg in
            let displayContent = msg.isEncrypted ? "<encrypted: \(msg.encryptedContent.map { "\($0.sealed.base64EncodedString().prefix(10))..." } ?? "?")>" : (msg.content ?? "<no content>")
            print("\r[\(displayName(of: msg.channel))] \(msg.author.displayName): \(displayContent)\r")
        }

        controller.onUpdatePresence { [unowned self] presence in
            let hasChanged = network.register(presence: presence)
            if hasChanged {
                print("\r> \(presence.user.displayName) is now \(presence.status.description.lowercased())\r")
            }
        }

        controller.onFindUser { [unowned self] id in
            network.presences[id]?.user
        }

        commands = [
            "help": { [unowned self] in
                print("\rAvailable commands: \(commands.keys.map { commandPrefix + $0 }.joined(separator: ", "))\r")
            },
            "network": { [unowned self] in
                print("\rCurrently reachable: \(network.presences.values.map { "\($0.user.displayName) (\($0.status.description.lowercased()))" }.joined(separator: ", "))\r")
            },
            "toggle-all-messages": { [unowned self] in
                controller.emitAllReceivedChatMessages = !controller.emitAllReceivedChatMessages
                if controller.emitAllReceivedChatMessages {
                    print("\rEnabled all messages, you will now get all incoming messages, even encrypted ones!\r")
                } else {
                    print("\rDisabled all messages, only those for you will be emitted from now!\r")
                }
            }
        ]
    }

    private func displayName(of channel: ChatChannel?) -> String {
        switch channel {
        case .dm(let userIds)?:
            let name = userIds
                .filter { $0 != controller.me.id }
                .map { network.presences[$0]?.user.displayName ?? $0.uuidString }
                .joined(separator: ",")
            return "@\(name)"
        case .room(let name)?:
            return "#\(name)"
        case nil:
            return "#\(globalChannelName)"
        }
    }

    private func parseChannel(from raw: String) -> ChatChannel? {
        let name = String(raw.dropFirst())
        switch raw.first {
        case "@"?:
            return resolveUser(from: name).map { .dm([controller.me.id, $0]) }
        case "#"?:
            return name == globalChannelName ? nil : .room(name)
        default:
            return nil
        }
    }

    private func parseMessage(from raw: String) -> (String, ChatChannel?) {
        let split = raw.split(separator: " ", maxSplits: 1).map(String.init)

        if split.count == 2, let channel = parseChannel(from: split[0]) {
            return (split[1], channel)
        } else {
            return (raw, nil) // on #global
        }
    }

    private func resolveUser(from raw: String) -> UUID? {
        network.presences.values.map(\.user).first { $0.displayName == raw }?.id
    }

    private func parseCommand(from raw: String) -> (() -> Void)? {
        guard raw.starts(with: commandPrefix) else { return nil }
        let commandName = String(raw.dropFirst(commandPrefix.count))
        return commands[commandName]
    }

    func run() {
        print("""
            ----------------------------------
            --- DISTRIBUTED CHAT REPL v0.1 ---
            ----------------------------------

            Type anything to send to #global or prefix your
            message with a channel, e.g. #my-channel or
            @SomeUserName. Note that the user has to be online.
            Type .help for a list of commands. Enjoy!

            """)

        let ln = LineNoise()

        ln.setCompletionCallback { [unowned self] buffer in
            commands.keys
                .map { commandPrefix + $0 }
                .filter { $0.hasPrefix(buffer) }
        }

        while let input = try? ln.getLine(prompt: "") {
            ln.addHistory(input)

            if let command = parseCommand(from: input) {
                command()
            } else {
                let (content, channel) = parseMessage(from: input)
                controller.send(content: content, on: channel)
            }
        }

        print()
    }
}
