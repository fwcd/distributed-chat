import Foundation
import LineNoise
import DistributedChat

struct ChatREPL {
    private let transport: ChatTransport
    private let controller: ChatController
    
    init(transport: ChatTransport, name: String) {
        self.transport = transport

        controller = ChatController(transport: transport)
        controller.update(name: name)

        controller.onAddChatMessage { msg in
            print("\r>> \(msg.author.displayName): \(msg.content)\r")
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
