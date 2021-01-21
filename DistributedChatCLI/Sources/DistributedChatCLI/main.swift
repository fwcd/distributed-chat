import ArgumentParser
import Dispatch
import DistributedChat
import Foundation
import LineNoise

struct DistributedChatCLI: ParsableCommand {
    @Argument(help: "The messaging WebSocket URL of the simulation server to connect to")
    var simulationMessagingURL: URL = URL(string: "ws://localhost:8080/messaging")!

    @Option(help: "The username to use")
    var name: String

    func run() {
        SimulationTransport.connect(url: simulationMessagingURL, name: name) {
            print("Connected to \(simulationMessagingURL)...")
            try! runREPL(transport: $0)
        }

        // Block the main thread
        dispatchMain()
    }

    private func runREPL(transport: ChatTransport) throws {
        let controller = ChatController(transport: transport)
        let ln = LineNoise()

        controller.update(name: name)

        while let input = try? ln.getLine(prompt: "") {
            ln.addHistory(input)
            print()

            controller.send(content: ChatMessageContent(text: input))
        }

        print()
    }
}

DistributedChatCLI.main()
