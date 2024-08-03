#if canImport(CoreBluetooth)
import CoreBluetooth
import Combine
import Dispatch
import DistributedChatKit
import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChatBluetooth.CoreBluetoothTransport")

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = CBUUID(string: "59553ceb-2ffa-4018-8a6c-453a5292044d")
/// Custom UUID for the (write-only) message inbox characteristic
fileprivate let inboxCharacteristicUUID = CBUUID(string: "440a594c-3cc2-494a-a08a-be8dd23549ff")
/// Custom UUID for the user name characteristic (used to display 'nearby' users)
fileprivate let userNameCharacteristicUUID = CBUUID(string: "b2234f40-2c0b-401b-8145-c612b9a7bae1")
/// Custom UUID for the user ID characteristic (user to display 'nearby' users)
fileprivate let userIDCharacteristicUUID = CBUUID(string: "13a4d26e-0a75-4fde-9340-4974e3da3100")

/// Determines how GATT characteristics (specifically the inbox) shall be written
fileprivate let writeType = CBCharacteristicWriteType.withResponse

/// A transport implementation that uses Bluetooth Low Energy and a
/// custom GATT service with a write-only characteristic to transfer
/// messages.
public class CoreBluetoothTransport: NSObject, ChatTransport, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    
    private var initializedPeripheral: Bool = false
    private var initializedCentral: Bool = false
    private var listeners = [(String) -> Void]()
    
    private let settings: AnyPublisher<CoreBluetoothSettings, Never>
    private let me: AnyPublisher<ChatUser, Never>
    private let onUpdateNearbyUsers: ([NearbyUser]) -> Void
    
    private var subscriptions = [AnyCancellable]()
    private var timer: AnyCancellable? = nil
    
    /// Tracks remote peripherals discovered by the central that feature our service's GATT characteristic.
    private var nearbyPeripherals: [CBPeripheral: DiscoveredPeripheral] = [:]
    
    /// Tracks remote centrals sending data through our service's GATT characteristic.
    private var nearbyCentrals: [CBCentral: DiscoveredCentral] = [:]
    
    /// A discovered, connected BLE peripheral (i.e. a remote other device).
    private class DiscoveredPeripheral: CustomStringConvertible {
        var isConnected: Bool = false // Only false while initially connecting
        var isDistributedChat: Bool = false
        var rssi: Int? = nil
        
        var inboxCharacteristic: CBCharacteristic? = nil
        var userNameCharacteristic: CBCharacteristic? = nil
        var userIDCharacteristic: CBCharacteristic? = nil
        
        var userID: UUID? = nil
        var userName: String? = nil
        
        var isWriting: Bool = false
        var outgoingData: Data = Data()
        
        var description: String { "DiscoveredPeripheral (isDistributedChat: \(isDistributedChat), userID: \(userID.map(\.uuidString) ?? "?"), userName: \(userName ?? "?")" }
        
        func dequeueChunk(length: Int) -> Data {
            let chunk = outgoingData.prefix(length)
            outgoingData.removeFirst(min(length, outgoingData.count))
            return chunk
        }
    }
    
    /// A discovered BLE central that currently sends data (i.e. a remote other device).
    private class DiscoveredCentral {
        var incomingData: Data = Data()
        
        /// Reads and removes the first line from the incoming data, however only if it is newline-terminated.
        func dequeueLine() -> String? {
            let nl = Character("\n").asciiValue!
            var lineData = Data()
            
            for b in incomingData {
                if b == nl {
                    incomingData.removeFirst(lineData.count + 1)
                    return String(data: lineData, encoding: .utf8)
                } else {
                    lineData.append(b)
                }
            }
            
            return nil
        }
    }

    public required init(
        settings: AnyPublisher<CoreBluetoothSettings, Never>,
        me: AnyPublisher<ChatUser, Never>,
        onUpdateNearbyUsers: @escaping ([NearbyUser]) -> Void
    ) {
        self.settings = settings
        self.me = me
        self.onUpdateNearbyUsers = onUpdateNearbyUsers
        
        super.init()
        
        // The app acts both as a peripheral (for receiving messages via an
        // exposed, writable GATT characteristic) and a central (for sending messages
        // and discovering nearby devices).
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func broadcast(_ raw: String) {
        log.info("Broadcasting \(raw) to \(nearbyPeripherals.count) nearby peripherals.")
        
        for (peripheral, state) in nearbyPeripherals where state.isConnected && state.inboxCharacteristic != nil {
            if let data = "\(raw)\n".data(using: .utf8) {
                state.outgoingData += data
                
                if !state.isWriting {
                    state.isWriting = true
                    writeOutgoingData(of: peripheral)
                }
            } else {
                log.warning("Could not encode data to UTF-8 for broadcasting")
            }
        }
    }
    
    public func onReceive(_ handler: @escaping (String) -> Void) {
        listeners.append(handler)
    }
    
    private func updateNetwork() {
        let peripherals = nearbyPeripherals
        log.trace("Updating network, nearby peripherals: \(peripherals)...")
        
        DispatchQueue.main.async { [self] in
            onUpdateNearbyUsers(
                peripherals.filter(\.value.isConnected).filter(\.value.isDistributedChat).map { (peripheral: CBPeripheral, discovered) in
                    NearbyUser(
                        peripheralIdentifier: peripheral.identifier,
                        peripheralName: peripheral.name,
                        chatUser: {
                            guard let userName = discovered.userName,
                                let userID = discovered.userID else { return nil }
                            return ChatUser(id: userID, name: userName)
                        }(),
                        rssi: discovered.rssi
                    )
                }.sorted { $0.id.uuidString < $1.id.uuidString } // An arbitrary, but stable ordering
            )
        }
    }
    
    // MARK: Peripheral implementation
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            log.info("Peripheral is powered on!")
            
            if !initializedPeripheral {
                initializedPeripheral = true
                publishService()
            }
        case .poweredOff:
            log.info("Peripheral is powered off!")
        default:
            // TODO: Handle other states
            log.info("Peripheral switched into state \(peripheral.state)")
        }
    }
    
    private func publishService() {
        log.info("Publishing DistributedChat GATT service...")
        
        let service = CBMutableService(type: serviceUUID, primary: true)
        let inboxCharacteristic = CBMutableCharacteristic(type: inboxCharacteristicUUID,
                                                          properties: [.write],
                                                          value: nil,
                                                          permissions: [.writeable])
        let userNameCharacteristic = CBMutableCharacteristic(type: userNameCharacteristicUUID,
                                                             properties: [.read],
                                                             value: nil,
                                                             permissions: [.readable])
        let userIDCharacteristic = CBMutableCharacteristic(type: userIDCharacteristicUUID,
                                                           properties: [.read],
                                                           value: nil,
                                                           permissions: [.readable])
        
        subscriptions.append(me.sink { user in
            userNameCharacteristic.value = user.name.data(using: .utf8)
            userIDCharacteristic.value = user.id.uuidString.data(using: .utf8)
        })
        
        service.characteristics = [inboxCharacteristic, userNameCharacteristic, userIDCharacteristic]
        peripheralManager.add(service)
        
        subscriptions.append(settings.sink { [unowned self] in
            if $0.advertisingEnabled {
                startAdvertising()
            } else {
                stopAdvertising()
            }
            
            timer?.cancel()
            timer = nil
            
            if $0.monitorSignalStrength {
                // Every five seconds, re-read the signal strengths of discovered (nearby) peripherals
                timer = Timer.publish(every: TimeInterval($0.monitorSignalStrengthInterval), on: .main, in: .default)
                    .autoconnect()
                    .sink { [unowned self] _ in
                        log.debug("Reading RSSIs")
                        for (peripheral, state) in nearbyPeripherals where state.isConnected {
                            peripheral.readRSSI()
                        }
                    }
            }
        })
    }
    
    private func startAdvertising() {
        log.info("Starting to advertise")
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "DistributedChat"
        ])
    }
    
    private func stopAdvertising() {
        log.info("Stopping advertisting")
        peripheralManager.stopAdvertising()
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests where request.characteristic.uuid == inboxCharacteristicUUID {
            // TODO: Deal with offset? This currently assumes that the requests are in the right order.
            
            let central = request.central
            
            if let data = request.value {
                log.info("Received write to inbox")
                
                let state = nearbyCentrals[central] ?? DiscoveredCentral()
                nearbyCentrals[central] = state
                
                // TODO: Perhaps limit the maximum incoming data length so malicious actors cannot fill up our memory?
                state.incomingData += data
                
                if writeType == .withResponse {
                    peripheralManager.respond(to: request, withResult: .success)
                }
                
                while let line = state.dequeueLine() {
                    log.info("Receive line via inbox: \(line)")
                    for listener in listeners {
                        listener(line)
                    }
                }
                
                if state.incomingData.isEmpty {
                    log.info("Finished reading data, dropping central state")
                    nearbyCentrals[central] = nil
                }
            }
        }
    }
    
    // MARK: Central implementation
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log.info("Central is powered on!")
            
            if !initializedCentral {
                initializedCentral = true
                
                subscriptions.append(settings.sink { [unowned self] in
                    if $0.scanningEnabled {
                        startScanning()
                    } else {
                        stopScanning()
                    }
                })
            }
        default:
            // TODO: Handle other states
            log.info("Central switched into state \(central.state)")
            break
        }
    }
    
    func startScanning() {
        log.info("Starting to scan")
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func stopScanning() {
        log.info("Stopping scan")
        centralManager.stopScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        peripheral.delegate = self
        
        if !nearbyPeripherals.keys.contains(peripheral) {
            log.info("Discovered remote peripheral \(peripheral.name ?? "?") with advertised name \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "?") (RSSI: \(rssi)")
            nearbyPeripherals[peripheral] = DiscoveredPeripheral()
            nearbyPeripherals[peripheral]?.isConnected = false
            centralManager.connect(peripheral)
        } else {
            log.debug("Remote peripheral \(peripheral.name ?? "?") has already been discovered!")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI rssi: NSNumber, error: Error?) {
        if let error = error {
            log.error("Error while reading RSSI: \(error)")
            return
        }
        guard let state = nearbyPeripherals[peripheral] else {
            log.warning("No state after reading RSSI")
            return
        }
        
        state.rssi = rssi.intValue
        updateNetwork()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("Did connect to remote peripheral, discovering services...")
        guard let state = nearbyPeripherals[peripheral] else {
            log.warning("No state after connecting to peripheral")
            return
        }
        
        state.isConnected = true
        peripheral.discoverServices([serviceUUID])
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            log.error("Error while discovering services: \(error)")
            return
        }
        
        log.debug("Discovered services on remote peripheral \(peripheral.name ?? "?")")
        
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            log.info("Found our DistributedChat service on the remote peripheral, looking for characteristic...")
            peripheral.discoverCharacteristics([inboxCharacteristicUUID, userNameCharacteristicUUID, userIDCharacteristicUUID], for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            log.error("Error while discovering characteristics: \(error)")
            return
        }
        
        log.info("Discovered characteristics on remote peripheral \(peripheral.name ?? "?")")
        
        if service.uuid == serviceUUID, let characteristics = service.characteristics {
            log.info("Found DistributedChat service on remote peripheral \(peripheral.name ?? "?") with \(characteristics.count) characteristics.")
            
            guard let state = nearbyPeripherals[peripheral] else {
                log.warning("No state after discovering characteristics for peripheral")
                return
            }
            
            state.isDistributedChat = true
            state.inboxCharacteristic = characteristics.first { $0.uuid == inboxCharacteristicUUID }
            state.userIDCharacteristic = characteristics.first { $0.uuid == userIDCharacteristicUUID }
            state.userNameCharacteristic = characteristics.first { $0.uuid == userNameCharacteristicUUID }
            updateNetwork()
            
            peripheral.readRSSI()
            
            for characteristic in characteristics where [userIDCharacteristicUUID, userNameCharacteristicUUID].contains(characteristic.uuid) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            log.error("Error while updating value for characteristic: \(error)")
            return
        }
        guard let state = nearbyPeripherals[peripheral] else {
            log.warning("No state after updating value for characteristic of peripheral")
            return
        }
        
        switch characteristic.uuid {
        case userIDCharacteristicUUID:
            log.info("Updating value for remote user ID characteristic...")
            state.userID = characteristic.value
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap { UUID(uuidString: $0) }
        case userNameCharacteristicUUID:
            log.info("Updating value for remote user name characteristic...")
            state.userName = characteristic.value
                .flatMap { String(data: $0, encoding: .utf8) }
        default:
            break
        }
    }
    
    func writeOutgoingData(of peripheral: CBPeripheral) {
        assert(nearbyPeripherals[peripheral]?.isWriting ?? false)
        let chunkLength = peripheral.maximumWriteValueLength(for: writeType)
        
        guard let state = nearbyPeripherals[peripheral],
              let characteristic = state.inboxCharacteristic else {
            log.warning("Not writing any outgoing data, missing state or characteristic for peripheral")
            return
        }
              
        let chunk = state.dequeueChunk(length: chunkLength)
        if state.outgoingData.isEmpty {
            state.isWriting = false
        }
        
        if !chunk.isEmpty {
            log.debug("Writing chunk of outgoing data: '\(String(data: chunk, encoding: .utf8) ?? "?")'")
            peripheral.writeValue(chunk, for: characteristic, type: writeType)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            log.error("Error while writing value for characteristic: \(error)")
            return
        }
        guard let state = nearbyPeripherals[peripheral] else {
            log.warning("Wrote characteristic, but no state for peripheral")
            return
        }
        
        log.debug("Did write value for characteristic, still writing: \(state.isWriting)")
        
        if state.isWriting {
            log.debug("Writing next chunk...")
            writeOutgoingData(of: peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log.info("Disconnected from remote peripheral \(peripheral.name ?? "?")")
        
        if let error = error {
            log.error("Error after disconnecting peripheral: \(error)")
        }
        
        nearbyPeripherals[peripheral] = nil
        updateNetwork()
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log.info("Failed to connect to remote peripheral \(peripheral.name ?? "?")")
        
        if let error = error {
            log.error("Error after failing to connect to peripheral: \(error)")
        }
        
        nearbyPeripherals[peripheral] = nil
        updateNetwork()
    }
}
#endif
