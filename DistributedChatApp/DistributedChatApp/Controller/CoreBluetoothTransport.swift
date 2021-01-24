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
fileprivate let characteristicUUID = CBUUID(string: "440a594c-3cc2-494a-a08a-be8dd23549ff")

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
    private var settingsSubscription: AnyCancellable?
    
    /// Tracks remote peripherals discovered by the central that feature our service's GATT characteristic.
    private var nearbyPeripherals: [CBPeripheral: DiscoveredPeripheral] = [:] {
        didSet {
            nearby.nearbyNodes = nearbyPeripherals.keys.map { $0.name ?? "Unknown" }.sorted()
        }
    }
    
    private class DiscoveredPeripheral {
        var characteristic: CBCharacteristic?
    }
    
    required init(settings: Settings, nearby: Nearby) {
        self.settings = settings
        self.nearby = nearby
        
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
            if let data = raw.data(using: .utf8), let characteristic = state.characteristic {
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
            
            settingsSubscription = settings.$bluetoothAdvertisingEnabled.sink { [unowned self] in
                if $0 {
                    startAdvertising()
                } else {
                    stopAdvertising()
                }
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
        let characteristic = CBMutableCharacteristic(type: characteristicUUID,
                                                     properties: [.write],
                                                     value: nil,
                                                     permissions: [.writeable])
        
        service.characteristics = [characteristic]
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
            centralManager.connect(peripheral)
        } else {
            log.info("Remote peripheral \(peripheral.name ?? "?") has already been discovered!")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log.info("Did connect to remote peripheral")
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        log.debug("Discovered services on remote peripheral \(peripheral.name ?? "?")")
        
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            log.info("Found our DistributedChat service on the remote peripheral, looking for characteristic...")
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        log.debug("Discovered characteristics on remote peripheral \(peripheral.name ?? "?")")
        
        if let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) {
            log.info("Found our DistributedChat characteristic on the remote peripheral \(peripheral.name ?? "?"), nice!")
            nearbyPeripherals[peripheral]?.characteristic = characteristic
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
