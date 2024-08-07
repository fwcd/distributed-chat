import ArgumentParser
import Dispatch
import DistributedChatBluetooth
import DistributedChatKit
import Foundation
import Logging
import LineNoise

fileprivate let log = Logger(label: "DistributedChatCLI.main")

struct DistributedChatCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "distributed-chat"
    )
    
    @Argument(help: "The messaging WebSocket URL of the simulation server to connect to.")
    var simulationMessagingURL: URL = URL(string: "ws://localhost:8080/messaging")!

    @Flag(help: """
        Use Bluetooth LE-based transport instead of the simulation server.
        This enables communication with 'real' iOS nodes and is currently only supported on Linux.
        Note that this also enables both central and peripheral mode by default, which requires 2 host controllers (i.e. bluetooth adapters). If you only want one of these modes, set --central-only or --peripheral-only.
        """)
    var bluetooth: Bool = false

    @Flag(help: """
        Whether to only act as a GATT central (i.e. only be able to send messages) via Bluetooth LE.
        Only used if --bluetooth is set.
        """)
    var centralOnly: Bool = false

    @Flag(help: """
        Whether to only act as a GATT peripheral (i.e. only be able to receive messages) via Bluetooth LE.
        Only used if --bluetooth is set.
        """)
    var peripheralOnly: Bool = false

    @Option(help: "The username to use.")
    var name: String = "\(ProcessInfo.processInfo.environment.keys.contains("IDE_DISABLED_OS_ACTIVITY_DT_MODE") ? "Xcode" : "CLI") User \(Int.random(in: 10_000..<100_000))"

    @Option(help: "The logging level")
    var level: Logger.Level = .info

    func run() async throws {
        LoggingSystem.bootstrap { label in
            CLILogHandler(label: label, logLevel: label.starts(with: "DistributedChatCLI.") ? level : .info)
        }

        let me = ChatUser(name: name)

        if bluetooth {
            try await runWithBluetoothLE(me: me)
        } else {
            runWithSimulationServer(me: me)
        }
    }

    private func runWithBluetoothLE(me: ChatUser) async throws {
        #if os(Linux)
        log.info("Initializing Bluetooth Linux transport...")

        var actAsCentral = centralOnly
        var actAsPeripheral = peripheralOnly

        if !centralOnly && !peripheralOnly {
            actAsCentral = true
            actAsPeripheral = true
        }

        let transport = try await BluetoothLinuxTransport(actAsPeripheral: actAsPeripheral, actAsCentral: actAsCentral, me: me)
        runREPL(transport: transport, me: me)
        #else
        log.error("The Bluetooth stack is currently Linux-only and requires BluetoothLinux! (TODO: Share the CoreBluetooth-based backend from the iOS app with a potential Mac version of the CLI)")
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
