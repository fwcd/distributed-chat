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

class CoreBluetoothTransport: NSObject, ChatTransport, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    
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
        
    }
    
    func onReceive(_ handler: @escaping (String) -> Void) {
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            log.info("Peripheral is powered on!")
        default:
            // TODO: Handle other states
            break
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log.info("Central is powered on!")
        default:
            // TODO: Handle other states
            break
        }
    }
}
