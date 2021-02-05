import Foundation
import LineNoise
import DistributedChat

class ChatREPL {
    private let transport: ChatTransport
    private let controller: ChatController
    private let network: Network = Network()
    
    init(transport: ChatTransport, name: String) {
        self.transport = transport

        controller = ChatController(transport: transport)
        controller.update(name: name)

        controller.onAddChatMessage { [unowned self] msg in
            print("\r[\(displayName(of: msg.channel))] \(msg.author.displayName): \(msg.content)\r")
        }

        controller.onUpdatePresence { [unowned self] presence in
            let hasChanged = network.register(presence: presence)
            if hasChanged {
                print("\r> \(presence.user.displayName) is now \(presence.status.description.lowercased())\r")
            }
        }
    }

    private func displayName(of channel: ChatChannel?) -> String {
        switch channel {
        case .dm(let userId)?:
            return "@\(network.presences[userId]?.user.displayName ?? userId.uuidString)"
        case .room(let name)?:
            return "#\(name)"
        case nil:
            return "#global"
        }
    }

    func run() {
        let ln = LineNoise()

        while let input = try? ln.getLine(prompt: "") {
            ln.addHistory(input)

            controller.send(content: input)
        }

        print()
    }
}
