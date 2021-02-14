#if os(Linux)
import DistributedChat
import Dispatch
import Foundation
import Logging
import BluetoothLinux
import GATT

fileprivate let log = Logger(label: "DistributedChatCLI.BluetoothLinuxTransport")

// TODO: Ideally move these constants into a module shared with the CoreBluetooth version
// TODO: Share more code with the CoreBluetooth variant (e.g. chunking)

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = BluetoothUUID(rawValue: "59553ceb-2ffa-4018-8a6c-453a5292044d")!
/// Custom UUID for the (write-only) message inbox characteristic
fileprivate let inboxCharacteristicUUID = BluetoothUUID(rawValue: "440a594c-3cc2-494a-a08a-be8dd23549ff")!
/// Custom UUID for the user name characteristic (used to display 'nearby' users)
fileprivate let userNameCharacteristicUUID = BluetoothUUID(rawValue: "b2234f40-2c0b-401b-8145-c612b9a7bae1")
/// Custom UUID for the user ID characteristic (user to display 'nearby' users)
fileprivate let userIDCharacteristicUUID = BluetoothUUID(rawValue: "13a4d26e-0a75-4fde-9340-4974e3da3100")

typealias GATTCentral = GATT.GATTCentral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>

public class BluetoothLinuxTransport: ChatTransport {
    private let localCentral: GATTCentral
    private let queue = DispatchQueue(label: "DistributedChatCLI.BluetoothLinuxTransport")

    private var nearbyPeripherals: [Peripheral: DiscoveredPeripheral] = [:]

    private class DiscoveredPeripheral {
        // TODO: Other characteristics
        var inboxCharacteristic: Characteristic<Peripheral>? = nil
    }

    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController.identifier) with address \(try! hostController.readDeviceAddress())")

        // TODO: Act as a peripheral too

        localCentral = GATTCentral(hostController: hostController)
        localCentral.newConnection = { (scanData, advReport) in
            try BluetoothLinux.L2CAPSocket.lowEnergyClient(
                destination: (address: advReport.address, type: .init(lowEnergy: advReport.addressType))
            )
        }
        localCentral.didDisconnect = { [unowned self] peripheral in
            log.info("Disconnected from \(peripheral.identifier)")
            nearbyPeripherals[peripheral] = nil
        }
        localCentral.log = { msg in
            log.debug("Internal: \(msg)")
        }

        queue.async { [weak self] in
            do {
                try self?.localCentral.scan(filterDuplicates: false) { scanData in
                    self?.handle(peripheralDiscovery: scanData)
                }
            } catch {
                log.error("Scanning failed: \(error)")
            }
        }
    }

    deinit {
        localCentral.stopScan()
    }

    private func handle(peripheralDiscovery scanData: ScanData<Peripheral, GATTCentral.Advertisement>) {
        let peripheral = scanData.peripheral
        log.debug("Discovered peripheral \(peripheral.identifier) (RSSI: \(scanData.rssi), connectable: \(scanData.isConnectable))")

        if !nearbyPeripherals.keys.contains(peripheral) {
            do {
                try localCentral.connect(to: peripheral)
                let state = DiscoveredPeripheral()
                nearbyPeripherals[peripheral] = state
                log.info("Connected to \(peripheral.identifier), discovering services...")

                let services = try localCentral.discoverServices([serviceUUID], for: peripheral)
                guard let service = services.first else { throw BluetoothLinuxError.noServices }
                log.info("Discovered DistributedChat service, discovering characteristics...")

                let characteristics = try localCentral.discoverCharacteristics([inboxCharacteristicUUID], for: service) // TODO: Discover user name/id
                guard let inboxCharacteristic = characteristics.first else { throw BluetoothLinuxError.noCharacteristics }
                log.info("Discovered inbox characteristic")

                state.inboxCharacteristic = inboxCharacteristic
            } catch {
                log.notice("Could not connect to/discover services on peripheral: \(error)")
            }
        }
    }

    public func broadcast(_ raw: String) {
        // TODO: 512 byte chunking
        guard let data = "\(raw)\n".data(using: .utf8) else {
            log.error("Could not encode string with UTF-8: '\(raw)'")
            return
        }

        for (peripheral, state) in nearbyPeripherals {
            if let characteristic = state.inboxCharacteristic {
                do {
                    try localCentral.writeValue(data, for: characteristic, withResponse: true)
                } catch {
                    log.warning("Could not send to \(peripheral.identifier): \(error)")
                }
            }
        }
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

