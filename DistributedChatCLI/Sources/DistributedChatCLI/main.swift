import ArgumentParser
import Dispatch
import DistributedChat
import Foundation
import Logging
import LineNoise

fileprivate let log = Logger(label: "DistributedChatCLI.main")

struct DistributedChatCLI: ParsableCommand {
    @Argument(help: "The messaging WebSocket URL of the simulation server to connect to.")
    var simulationMessagingURL: URL = URL(string: "ws://localhost:8080/messaging")!

    @Flag(help: "Use Bluetooth LE-based transport instead of the simulation server. This enables communication with 'real' iOS nodes. Currently only supported on Linux.")
    var bluetooth: Bool = false

    @Option(help: "The username to use.")
    var name: String

    func run() throws {
        LoggingSystem.bootstrap { CLILogHandler(label: $0) }

        if bluetooth {
            try runWithBluetoothLE()
        } else {
            runWithSimulationServer()
        }
    }

    private func runWithBluetoothLE() throws {
        #if os(Linux)
        log.info("Initializing Bluetooth Linux transport...")
        try runREPL(transport: BluetoothLinuxTransport())
        #else
        log.error("The Bluetooth stack is currently Linux-only! (TODO: Share the CoreBluetooth-based backend from the iOS app with a potential Mac version of the CLI)")
        #endif
    }

    private func runWithSimulationServer() {
        log.info("Connecting to \(simulationMessagingURL)...")

        SimulationTransport.connect(url: simulationMessagingURL, name: name) { transport in
            DispatchQueue.main.async {
                log.info("Connected to \(simulationMessagingURL)")
                try! runREPL(transport: transport)
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
