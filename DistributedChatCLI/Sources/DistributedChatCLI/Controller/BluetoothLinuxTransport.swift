#if os(Linux)
import DistributedChat
import Dispatch
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
    private let queue = DispatchQueue(label: "DistributedChatCLI.BluetoothLinuxTransport")

    private var nearbyPeripherals: [Peripheral: DiscoveredPeripheral] = [:]

    private class DiscoveredPeripheral {
        // TODO
    }

    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController.identifier) with address \(try! hostController.readDeviceAddress())")

        // TODO: Act as a peripheral too

        central = GATTCentral(hostController: hostController)
        central.newConnection = { (scanData, advReport) in
            try BluetoothLinux.L2CAPSocket(
                controllerAddress: advReport.address,
                addressType: .init(lowEnergy: advReport.addressType)
            )
        }
        central.didDisconnect = { [unowned self] peripheral in
            log.info("Disconnected from \(peripheral.identifier)")
            nearbyPeripherals[peripheral] = nil
        }

        queue.async { [weak self] in
            do {
                try self?.central.scan(filterDuplicates: false) { scanData in
                    self?.handle(peripheralDiscovery: scanData)
                }
            } catch {
                log.error("Scanning failed: \(error)")
            }
        }
    }

    deinit {
        central.stopScan()
    }

    private func handle(peripheralDiscovery scanData: ScanData<Peripheral, GATTCentral.Advertisement>) {
        let peripheral = scanData.peripheral
        log.info("Discovered peripheral \(peripheral.identifier) (RSSI: \(scanData.rssi), connectable: \(scanData.isConnectable))")

        if !nearbyPeripherals.keys.contains(peripheral) {
            do {
                try central.connect(to: peripheral)
                nearbyPeripherals[peripheral] = DiscoveredPeripheral()

                log.info("Connected to \(peripheral.identifier)")
            } catch {
                log.notice("Could not connect to peripheral: \(error)")
            }
        }
    }

    public func broadcast(_ raw: String) {
        // TODO
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

