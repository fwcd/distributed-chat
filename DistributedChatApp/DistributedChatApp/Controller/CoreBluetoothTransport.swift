//
//  CoreBluetoothTransport.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import CoreBluetooth
import DistributedChat
import Foundation
import Logging

fileprivate let log = Logger(label: "CoreBluetoothTransport")

/// Custom UUID specifically for the 'Distributed Chat' service
fileprivate let serviceUUID = CBUUID(string: "59553ceb-2ffa-4018-8a6c-453a5292044d")
/// Custom UUID specific to the characteristic holding the L2CAP channel's PSM (see below)
fileprivate let characteristicUUID = CBUUID(string: "440a594c-3cc2-494a-a08a-be8dd23549ff")

class CoreBluetoothTransport: NSObject, ChatTransport, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    
    private var characteristic: CBMutableCharacteristic?
    private var psm: CBL2CAPPSM?
    
    /// Tracks remote peripherals discovered by the central. Note that out-of-range
    /// peripherals are not automatically removed from the set, this happens first after an
    /// unsuccessful attempt to send a message to it.
    private var nearbyPeripherals: Set<CBPeripheral> = []
    
    override init() {
        super.init()
        
        // The app acts both as a peripheral (for receiving messages and
        // exposing an L2CAP channel) and a central (for sending messages
        // and discovering nearby devices).
        //
        // The peripheral is responsible for opening an L2CAP channel. For this,
        // CoreBluetooth assigns it a free PSM, which it then advertises
        // using a GATT characteristic.
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func broadcast(_ raw: String) {
        // TODO
    }
    
    func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
    
    // MARK: Peripheral implementation
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            log.info("Peripheral is powered on!")
            peripheral.publishL2CAPChannel(withEncryption: true)
        case .poweredOff:
            log.info("Peripheral is powered off!")
        default:
            // TODO: Handle other states
            log.info("Peripheral switched into state \(peripheral.state)")
            break
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel psm: CBL2CAPPSM, error: Error?) {
        log.info("Published L2CAP channel with PSM \(psm)")
        
        // Now that CoreBluetooth has assigned us a PSM for the L2CAP channel,
        // publish it through the GATT characteristic. Note that we do not
        // set the value directly, instead we wait for a read. This is due
        // to iOS' caching policies.
        
        self.psm = psm
        let service = CBMutableService(type: serviceUUID, primary: true)
        let characteristic = CBMutableCharacteristic(type: characteristicUUID,
                                                     properties: [.writeWithoutResponse],
                                                     value: nil,
                                                     permissions: [.readable])
        
        service.characteristics = [characteristic]
        peripheralManager.add(service)
        self.characteristic = characteristic
        
        log.info("Starting to advertise")
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "DistributedChat"
        ])
        // TODO: unpublishL2CAPChannel e.g. through a UI switch for disabling connectivity
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        log.info("Did start advertising")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        log.info("Stopping advertisting")
        peripheralManager.stopAdvertising()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        log.info("Got a GATT read request")
        
        if var psm = psm, let characteristic = characteristic {
            log.info("...and we do have a PSM to offer!")
            
            let data = Data(bytes: &psm, count: MemoryLayout.size(ofValue: psm))
            peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
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
        guard rssi.intValue >= -50 else {
            log.notice("Discovered peripheral \(peripheral.name ?? "?"), but RSSI is too weak (\(rssi))")
            return
        }
        
        log.info("Discovered peripheral \(peripheral.name ?? "?") successfully (RSSI: \(rssi)")
        nearbyPeripherals.insert(peripheral)
    }
}
