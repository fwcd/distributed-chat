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

    @Option(help: "The logging level")
    var level: Logger.Level = .info

    func run() throws {
        LoggingSystem.bootstrap { label in
            CLILogHandler(label: label, logLevel: label.starts(with: "DistributedChatCLI.") ? level : .info)
        }

        let me = ChatUser(name: name)

        if bluetooth {
            try runWithBluetoothLE(me: me)
        } else {
            runWithSimulationServer(me: me)
        }
    }

    private func runWithBluetoothLE(me: ChatUser) throws {
        #if os(Linux)
        log.info("Initializing Bluetooth Linux transport...")
        try runREPL(transport: BluetoothLinuxTransport(me: me), me: me)
        #else
        log.error("The Bluetooth stack is currently Linux-only! (TODO: Share the CoreBluetooth-based backend from the iOS app with a potential Mac version of the CLI)")
        #endif
    }

    private func runWithSimulationServer(me: ChatUser) {
        log.info("Connecting to \(simulationMessagingURL)...")

        SimulationTransport.connect(url: simulationMessagingURL, name: name) { transport in
            DispatchQueue.main.async {
                log.info("Connected to \(simulationMessagingURL)")
                runREPL(transport: transport, me: me)
            }
        }

        // Block the main thread
        dispatchMain()
    }

    private func runREPL(transport: ChatTransport, me: ChatUser) {
        let repl = ChatREPL(transport: transport, me: me)
        repl.run()
        Foundation.exit(EXIT_SUCCESS)
    }
}

DistributedChatCLI.main()
