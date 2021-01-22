//
//  CoreBluetoothTransport.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/22/21.
//

import CoreBluetooth
import DistributedChat
import Foundation

class CoreBluetoothTransport: NSObject, ChatTransport, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func broadcast(_ raw: String) {
        
    }
    
    func onReceive(_ handler: @escaping (String) -> Void) {
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // TODO
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO
    }
}
