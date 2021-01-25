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
    
    private var initialized: Bool = false
    private var listeners = [(String) -> Void]()
    
    private let nearby: Nearby
    private let settings: Settings
    private let profile: Profile
    
    private var subscriptions = [AnyCancellable]()
    
    /// Tracks remote peripherals discovered by the central that feature our service's GATT characteristic.
    private var nearbyPeripherals: [CBPeripheral: DiscoveredPeripheral] = [:] {
        didSet {
            nearby.nearbyUsers = nearbyPeripherals.values.compactMap { dp in
                guard let userNameData = dp.userNameCharacteristic?.value,
                      let userIDData = dp.userIDCharacteristic?.value,
                      let userName = String(data: userNameData, encoding: .utf8),
                      let userIDString = String(data: userIDData, encoding: .utf8),
                      let userID = UUID(uuidString: userIDString) else { return nil }
                return NearbyUser(user: ChatUser(id: userID, name: userName), rssi: dp.rssi)
            }.sorted { $0.user.displayName < $1.user.displayName }
        }
    }
    
    private class DiscoveredPeripheral {
        var rssi: Int?
        var inboxCharacteristic: CBCharacteristic?
        var userNameCharacteristic: CBCharacteristic?
        var userIDCharacteristic: CBCharacteristic?
    }
    
    required init(settings: Settings, nearby: Nearby, profile: Profile) {
        self.settings = settings
        self.nearby = nearby
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
            if let data = raw.data(using: .utf8), let characteristic = state.inboxCharacteristic {
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
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
            
            if !initialized {
                initialized = true
                publishService()
            }
            
            if settings.bluetoothAdvertisingEnabled {
                startAdvertising()
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
        
        userNameCharacteristic.value = profile.me.name.data(using: .utf8)
        userIDCharacteristic.value = profile.me.id.uuidString.data(using: .utf8)
        
        subscriptions.append(profile.$me.sink { me in
            userNameCharacteristic.value = me.name.data(using: .utf8)
            userIDCharacteristic.value = me.id.uuidString.data(using: .utf8)
        })
        
        subscriptions.append(settings.$bluetoothAdvertisingEnabled.sink { [unowned self] in
            if $0 {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        })
        
        // Every five seconds, re-read the signal strengths of discovered (nearby) peripherals
        subscriptions.append(Timer.publish(every: 5, on: .main, in: .default)
            .autoconnect()
            .sink { [unowned self] _ in
                for peripheral in nearbyPeripherals.keys {
                    peripheral.readRSSI()
                }
            })
        
        service.characteristics = [inboxCharacteristic, userNameCharacteristic, userIDCharacteristic]
        peripheralManager.add(service)
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
            // TODO: Deal with offset?
            if let data = request.value, let str = String(data: data, encoding: .utf8) {
                log.info("Received write to inbox: '\(str)'")
                
                for listener in listeners {
                    listener(str)
                }
                
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
    // MARK: Central implementation
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log.info("Central is powered on, scanning for peripherals!")
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        default:
            // TODO: Handle other states
            log.info("Central switched into state \(central.state)")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        log.info("Discovered remote peripheral \(peripheral.name ?? "?") with advertised name \(advertisementData[CBAdvertisementDataLocalNameKey] ?? "?") (RSSI: \(rssi)")
        
        peripheral.delegate = self
        
        if !nearbyPeripherals.keys.contains(peripheral) {
            nearbyPeripherals[peripheral] = DiscoveredPeripheral()
            
            peripheral.readRSSI()
            centralManager.connect(peripheral)
        } else {
            log.info("Remote peripheral \(peripheral.name ?? "?") has already been discovered!")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI rssi: NSNumber, error: Error?) {
        nearbyPeripherals[peripheral]?.rssi = rssi.intValue
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("Did connect to remote peripheral")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log.debug("Discovered services on remote peripheral \(peripheral.name ?? "?")")
        
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            log.info("Found our DistributedChat service on the remote peripheral, looking for characteristic...")
            peripheral.discoverCharacteristics([inboxCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        log.debug("Discovered characteristics on remote peripheral \(peripheral.name ?? "?")")
        
        if let characteristic = service.characteristics?.first(where: { $0.uuid == inboxCharacteristicUUID }) {
            log.info("Found our DistributedChat characteristic on the remote peripheral \(peripheral.name ?? "?"), nice!")
            nearbyPeripherals[peripheral]?.inboxCharacteristic = characteristic
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
