#if os(Linux)
import DistributedChat
import Dispatch
import Foundation
import Logging
import BluetoothLinux
import GATT

fileprivate let log = Logger(label: "DistributedChatCLI.BluetoothLinuxTransport")

// TODO: Genericize this class by parameterizing over HostController/L2CAP like GATTCentral/GATTPeripheral
// TODO: Ideally move these constants into a module shared with the CoreBluetooth version
// TODO: Share more code with the CoreBluetooth variant (e.g. chunking)

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = BluetoothUUID(rawValue: "59553ceb-2ffa-4018-8a6c-453a5292044d")!
/// Custom UUID for the (write-only) message inbox characteristic
fileprivate let inboxCharacteristicUUID = BluetoothUUID(rawValue: "440a594c-3cc2-494a-a08a-be8dd23549ff")!
/// Custom UUID for the user name characteristic (used to display 'nearby' users)
fileprivate let userNameCharacteristicUUID = BluetoothUUID(rawValue: "b2234f40-2c0b-401b-8145-c612b9a7bae1")!
/// Custom UUID for the user ID characteristic (user to display 'nearby' users)
fileprivate let userIDCharacteristicUUID = BluetoothUUID(rawValue: "13a4d26e-0a75-4fde-9340-4974e3da3100")!

typealias GATTCentral = GATT.GATTCentral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>
typealias GATTPeripheral = GATT.GATTPeripheral<BluetoothLinux.HostController, BluetoothLinux.L2CAPSocket>

public class BluetoothLinuxTransport: ChatTransport {
    private let localCentral: GATTCentral?
    private let localPeripheral: GATTPeripheral?

    private let centralQueue = DispatchQueue(label: "DistributedChatCLI.BluetoothLinuxTransport: Central")
    private let peripheralQueue = DispatchQueue(label: "DistributedChatCLI.BluetoothLinuxTransport: Peripheral")

    private var nearbyPeripherals: [Peripheral: DiscoveredPeripheral] = [:]

    private class DiscoveredPeripheral {
        // TODO: Other characteristics
        var inboxCharacteristic: Characteristic<Peripheral>? = nil
    }

    public init(
        actAsPeripheral: Bool = true,
        actAsCentral: Bool = true,
        me: ChatUser
    ) throws {
        // Set up controllers. Note that you need at least 2 controller if
        // you want to run both as a peripheral and central (which is required
        // to both send and receive messages).

        let requiredCount = [actAsCentral, actAsPeripheral].filter { $0 }.count
        var hostControllers = BluetoothLinux.HostController.controllers
        log.info("Found host controllers \(hostControllers.map(\.identifier))")

        if hostControllers.count < requiredCount {
            throw BluetoothLinuxError.tooFewHostControllers("At least \(requiredCount) host controller(s) are required, but only \(hostControllers.count) was/were found.")
        }

        localPeripheral = actAsPeripheral ? GATTPeripheral(controller: hostControllers.popLast()!) : nil
        localCentral = actAsCentral ? GATTCentral(hostController: hostControllers.popLast()!) : nil

        // Set up local GATT peripheral for receiving messages

        if let localPeripheral = localPeripheral {
            localPeripheral.log = { msg in
                log.info("Peripheral (internal): \(msg)")
            }
            localPeripheral.willWrite = { [unowned self] request in
                log.info("Peripheral: Got write request: \(request)")
                // TODO
                return nil
            }

            try localPeripheral.add(service: .init(
                uuid: serviceUUID,
                primary: true,
                characteristics: [
                    .init(
                        uuid: inboxCharacteristicUUID,
                        permissions: [.write],
                        properties: [.write]
                    ),
                    .init(
                        uuid: userNameCharacteristicUUID,
                        // TODO: value
                        permissions: [.read],
                        properties: [.read]
                    ),
                    .init(
                        uuid: userIDCharacteristicUUID,
                        // TODO: value
                        permissions: [.read],
                        properties: [.read]
                    )
                ]
            ))

            let serverSocket = try BluetoothLinux.L2CAPSocket.lowEnergyServer()
            localPeripheral.newConnection = {
                let clientSocket = try serverSocket.waitForConnection()
                return (socket: clientSocket, central: Central(identifier: clientSocket.address))
            }

            peripheralQueue.async {
                do {
                    try localPeripheral.start()
                } catch {
                    log.error("Peripheral: Starting failed: \(error)")
                }
            }
        }

        // Set up local GATT central for sending messages

        if let localCentral = localCentral {
            localCentral.didDisconnect = { [unowned self] peripheral in
                log.info("Central: Disconnected from \(peripheral.identifier)")
                nearbyPeripherals[peripheral] = nil
            }
            localCentral.log = { msg in
                log.debug("Central: (internal) \(msg)")
            }

            localCentral.newConnection = { (scanData, advReport) in
                try BluetoothLinux.L2CAPSocket.lowEnergyClient(
                    destination: (address: advReport.address, type: .init(lowEnergy: advReport.addressType))
                )
            }

            centralQueue.async { [weak self] in
                do {
                    try localCentral.scan(filterDuplicates: false) { scanData in
                        self?.handle(peripheralDiscovery: scanData)
                    }
                } catch {
                    log.error("Central: Scanning failed: \(error)")
                }
            }
        }
    }

    deinit {
        localCentral?.stopScan()
        localPeripheral?.stop()
    }

    private func handle(peripheralDiscovery scanData: ScanData<Peripheral, GATTCentral.Advertisement>) {
        guard let localCentral = localCentral else { return }

        let peripheral = scanData.peripheral
        log.debug("Central: Discovered peripheral \(peripheral.identifier) (RSSI: \(scanData.rssi), connectable: \(scanData.isConnectable))")

        if !nearbyPeripherals.keys.contains(peripheral) {
            do {
                try localCentral.connect(to: peripheral)
                let state = DiscoveredPeripheral()
                nearbyPeripherals[peripheral] = state
                log.info("Central: Connected to \(peripheral.identifier), discovering services...")

                let services = try localCentral.discoverServices([serviceUUID], for: peripheral)
                log.debug("Central: Discovered services \(services)")
                guard let service = services.first(where: { $0.uuid == serviceUUID }) else { throw BluetoothLinuxError.noServices }
                log.info("Central: Discovered DistributedChat service, discovering characteristics...")

                let characteristics = try localCentral.discoverCharacteristics([inboxCharacteristicUUID], for: service) // TODO: Discover user name/id
                log.debug("Central: Discovered characteristics \(characteristics)")
                guard let inboxCharacteristic = characteristics.first(where: { $0.uuid == inboxCharacteristicUUID }) else { throw BluetoothLinuxError.noCharacteristics }
                log.info("Central: Discovered inbox characteristic")

                state.inboxCharacteristic = inboxCharacteristic
            } catch {
                log.notice("Central: Could not connect to/discover services on peripheral: \(error)")
            }
        }
    }

    public func broadcast(_ raw: String) {
        guard let localCentral = localCentral else { return }

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

