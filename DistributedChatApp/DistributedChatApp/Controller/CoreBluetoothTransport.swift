//
//  CoreBluetoothTransport.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import CoreBluetooth
import Combine
import DistributedChat
import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.CoreBluetoothTransport")

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = CBUUID(string: "59553ceb-2ffa-4018-8a6c-453a5292044d")
/// Custom UUID for the (write-only) message inbox characteristic
fileprivate let inboxCharacteristicUUID = CBUUID(string: "440a594c-3cc2-494a-a08a-be8dd23549ff")
/// Custom UUID for the user name characteristic (used to display 'nearby' users)
fileprivate let userNameCharacteristicUUID = CBUUID(string: "b2234f40-2c0b-401b-8145-c612b9a7bae1")
/// Custom UUID for the user ID characteristic (user to display 'nearby' users)
fileprivate let userIDCharacteristicUUID = CBUUID(string: "13a4d26e-0a75-4fde-9340-4974e3da3100")

/// A transport implementation that uses Bluetooth Low Energy and a
/// custom GATT service with a write-only characteristic to transfer
/// messages.
class CoreBluetoothTransport: NSObject, ChatTransport, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    
    private var initializedPeripheral: Bool = false
    private var initializedCentral: Bool = false
    private var listeners = [(String) -> Void]()
    
    private let network: Network
    private let settings: Settings
    private let profile: Profile
    
    private var subscriptions = [AnyCancellable]()
    private var timer: AnyCancellable? = nil
    
    /// Tracks remote peripherals discovered by the central that feature our service's GATT characteristic.
    private var nearbyPeripherals: [CBPeripheral: DiscoveredPeripheral] = [:] {
        didSet {
            log.debug("Updating nearby users...")
            network.nearbyUsers = nearbyPeripherals.filter(\.value.isDistributedChat).map { (peripheral: CBPeripheral, discovered) in
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
        }
    }
    
    /// Tracks remote centrals sending data through our service's GATT characteristic.
    private var nearbyCentrals: [CBCentral: DiscoveredCentral] = [:]
    
    /// A discovered, connected BLE peripheral (i.e. a remote other device).
    private class DiscoveredPeripheral {
        var isDistributedChat: Bool = false
        var rssi: Int? = nil
        
        var inboxCharacteristic: CBCharacteristic? = nil
        var userNameCharacteristic: CBCharacteristic? = nil
        var userIDCharacteristic: CBCharacteristic? = nil
        
        var userID: UUID? = nil
        var userName: String? = nil
        
        var isWriting: Bool = false
        var outgoingData: Data = Data()
        
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
    
    required init(settings: Settings, network: Network, profile: Profile) {
        self.settings = settings
        self.network = network
        self.profile = profile
        
        super.init()
        
        // The app acts both as a peripheral (for receiving messages via an
        // exposed, writable GATT characteristic) and a central (for sending messages
        // and discovering nearby devices).
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func broadcast(_ raw: String) {
        log.info("Broadcasting \(raw) to \(nearbyPeripherals.count) nearby peripherals.")
        
        for (peripheral, state) in nearbyPeripherals {
            if let data = "\(raw)\n".data(using: .utf8), state.inboxCharacteristic != nil {
                state.outgoingData += data
                if !state.isWriting {
                    state.isWriting = true
                    writeOutgoingData(of: peripheral)
                }
            }
        }
    }
    
    func onReceive(_ handler: @escaping (String) -> Void) {
        listeners.append(handler)
    }
    
    // MARK: Peripheral implementation
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
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
        
        subscriptions.append(profile.$presence.sink { presence in
            userNameCharacteristic.value = presence.user.name.data(using: .utf8)
            userIDCharacteristic.value = presence.user.id.uuidString.data(using: .utf8)
        })
        
        service.characteristics = [inboxCharacteristic, userNameCharacteristic, userIDCharacteristic]
        peripheralManager.add(service)
        
        subscriptions.append(settings.$bluetooth.sink { [unowned self] in
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
                        for peripheral in nearbyPeripherals.keys {
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
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            // TODO: Deal with offset? This currently assumes that the requests are in the right order.
            
            let central = request.central
            
            if let data = request.value, let str = String(data: data, encoding: .utf8) {
                log.info("Received write to inbox: '\(str)'")
                
                let state = nearbyCentrals[central] ?? DiscoveredCentral()
                nearbyCentrals[central] = state
                
                // TODO: Perhaps limit the maximum incoming data length so malicious actors cannot fill up our memory?
                state.incomingData += data
                peripheralManager.respond(to: request, withResult: .success)
                
                while let line = state.dequeueLine() {
                    for listener in listeners {
                        listener(line)
                    }
                }
            }
        }
    }
    
    // MARK: Central implementation
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log.info("Central is powered on!")
            
            if !initializedCentral {
                initializedCentral = true
                
                if settings.bluetooth.scanningEnabled {
                    startScanning()
                }
                
                subscriptions.append(settings.$bluetooth.sink { [unowned self] in
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        peripheral.delegate = self
        
        if !nearbyPeripherals.keys.contains(peripheral) {
            log.info("Discovered remote peripheral \(peripheral.name ?? "?") with advertised name \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "?") (RSSI: \(rssi)")
            nearbyPeripherals[peripheral] = DiscoveredPeripheral()
            centralManager.connect(peripheral)
        } else {
            log.debug("Remote peripheral \(peripheral.name ?? "?") has already been discovered!")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI rssi: NSNumber, error: Error?) {
        nearbyPeripherals[peripheral]?.rssi = rssi.intValue
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("Did connect to remote peripheral, discovering services...")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log.debug("Discovered services on remote peripheral \(peripheral.name ?? "?")")
        
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            log.info("Found our DistributedChat service on the remote peripheral, looking for characteristic...")
            peripheral.discoverCharacteristics([inboxCharacteristicUUID, userNameCharacteristicUUID, userIDCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        log.info("Discovered characteristics on remote peripheral \(peripheral.name ?? "?")")
        
        if service.uuid == serviceUUID, let characteristics = service.characteristics, let state = nearbyPeripherals[peripheral] {
            log.info("Found DistributedChat service on remote peripheral \(peripheral.name ?? "?") with \(characteristics.count) characteristics.")
            
            state.isDistributedChat = true
            state.inboxCharacteristic = characteristics.first { $0.uuid == inboxCharacteristicUUID }
            state.userIDCharacteristic = characteristics.first { $0.uuid == userIDCharacteristicUUID }
            state.userNameCharacteristic = characteristics.first { $0.uuid == userNameCharacteristicUUID }
            
            peripheral.readRSSI()
            
            for characteristic in characteristics where [userIDCharacteristicUUID, userNameCharacteristicUUID].contains(characteristic.uuid) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let state = nearbyPeripherals[peripheral]
        
        switch characteristic.uuid {
        case userIDCharacteristicUUID:
            state?.userID = characteristic.value
                .flatMap { String(data: $0, encoding: .utf8) }
                .flatMap { UUID(uuidString: $0) }
        case userNameCharacteristicUUID:
            state?.userName = characteristic.value
                .flatMap { String(data: $0, encoding: .utf8) }
        default:
            break
        }
    }
    
    func writeOutgoingData(of peripheral: CBPeripheral) {
        let chunkLength = peripheral.maximumWriteValueLength(for: .withResponse)
        
        if let state = nearbyPeripherals[peripheral] {
            assert(state.isWriting)
            
            if let characteristic = state.inboxCharacteristic {
                let chunk = state.dequeueChunk(length: chunkLength)
                peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
                
                if state.outgoingData.isEmpty {
                    state.isWriting = false
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let state = nearbyPeripherals[peripheral], state.isWriting {
            writeOutgoingData(of: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log.info("Disconnected from remote peripheral \(peripheral.name ?? "?")")
        
        nearbyPeripherals[peripheral] = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log.info("Failed to connect to remote peripheral \(peripheral.name ?? "?")")
        
        nearbyPeripherals[peripheral] = nil
    }
}
