import ArgumentParser
import Dispatch
import DistributedChat
import Foundation

struct DistributedChatCLI: ParsableCommand {
    @Argument(help: "The messaging WebSocket URL of the simulation server to connect to")
    var simulationMessagingURL: URL = URL(string: "ws://localhost:8080/messaging")!

    @Option(help: "The username to use")
    var name: String

    func run() {
        print("Connecting to \(simulationMessagingURL)...")

        SimulationTransport.connect(url: simulationMessagingURL, name: name) { transport in
            DispatchQueue.main.async {
                print("Connected to \(simulationMessagingURL)")
                runREPL(transport: transport)
            }
        }

        // Block the main thread
        dispatchMain()
    }

    private func runREPL(transport: ChatTransport) {
        let repl = ChatREPL(transport: transport, name: name)
        repl.run()
        Foundation.exit(EXIT_SUCCESS)
    }
}

DistributedChatCLI.main()
