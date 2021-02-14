#if os(Linux)
import DistributedChat
import Foundation
import Logging
import BluetoothLinux
import GATT

fileprivate let log = Logger(label: "DistributedChatCLI.BluetoothLinuxTransport")

// TODO: Ideally move these constants into a module shared with the CoreBluetooth version

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = UUID(uuidString: "59553ceb-2ffa-4018-8a6c-453a5292044d")!
/// Custom UUID specific to the characteristic holding the L2CAP channel's PSM (see below)
fileprivate let characteristicUUID = UUID(uuidString: "440a594c-3cc2-494a-a08a-be8dd23549ff")!

typealias GATTCentral = GATT.GATTCentral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>

public class BluetoothLinuxTransport: ChatTransport {
    private let central: GATTCentral

    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController.identifier) with address \(try! hostController.readDeviceAddress())")

        central = GATTCentral(hostController: hostController)
        central.newConnection = { (scanData, advReport) in
            try BluetoothLinux.L2CAPSocket(controllerAddress: scanData.peripheral.identifier)
        }

        try central.scan(foundDevice: handle(peripheralDiscovery:))
    }

    deinit {
        central.stopScan()
    }

    private func handle(peripheralDiscovery scanData: ScanData<Peripheral, GATTCentral.Advertisement>) {
        log.info("Discovered peripheral \(scanData.peripheral.identifier) (RSSI: \(scanData.rssi), connectable: \(scanData.isConnectable))")
    }

    public func broadcast(_ raw: String) {
        // TODO
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

