import Foundation
import LineNoise
import DistributedChat

fileprivate let globalChannelName = "global"

class ChatREPL {
    private let transport: ChatTransport
    private let controller: ChatController
    private let network: Network = Network()
    
    init(transport: ChatTransport, name: String) {
        self.transport = transport

        controller = ChatController(transport: transport)
        controller.update(name: name)

        controller.onAddChatMessage { [unowned self] msg in
            let displayContent = msg.isEncrypted ? "<encrypted>" : (msg.content ?? "<no content>")
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

    func run() {
        print("""
            ----------------------------------
            --- DISTRIBUTED CHAT REPL v0.1 ---
            ----------------------------------

            Type anything to send to #global or prefix your message
            with a channel, e.g. #my-channel or @SomeUserName.
            Note that the user has to be online. Enjoy!

            """)

        let ln = LineNoise()

        while let input = try? ln.getLine(prompt: "") {
            ln.addHistory(input)

            let (content, channel) = parseMessage(from: input)
            controller.send(content: content, on: channel)
        }

        print()
    }
}
