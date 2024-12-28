//
//  BlePeripheralService.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import CoreBluetooth
import SwiftUI

class BlePeripheralService: PeripheralService, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Private Variables
    private var centralMngr: CBCentralManager?
    private var services: [CBUUID]
    
    
    
    // Initializer
    override init() {
        // Reference to CB Manager
        self.centralMngr = nil
        self.services = []
    }
    
    
    
    // Public Methods
    override func start() {
        // Start the Core Bluetooth Central
        centralMngr = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func registerServices(services: [String]) {
        self.services.append(contentsOf: services.map({CBUUID(string: $0)}))
        if state == .scanning {
            centralMngr?.stopScan()
            foundDevices.removeAll()
            centralMngr?.scanForPeripherals(withServices: self.services)
        }
    }
    
    override func unregisterServices(services: [String]) {
        for service in services.map({CBUUID(string: $0)}) {
            if let idx = self.services.firstIndex(of: service) {
                self.services.remove(at:idx)
            }
        }
    }
    
    override func startScanning() {
        // Start scanning for devices
        if state == .on {
            centralMngr?.scanForPeripherals(withServices: services)
            state = .scanning
        }
    }
    
    override func stopScanning() {
        // Stop Scanning
        if state == .scanning {
            centralMngr?.stopScan()
            state = .on
        }
    }
    
    
    
    // Service Specific Functions
    func connect(peripheral: CBPeripheral) {
        if state == .on || state == .scanning {
            centralMngr?.connect(peripheral, options: nil)
        }
    }
    
    func disconnect(peripheral: CBPeripheral) {
        if state == .on || state == .scanning {
            centralMngr?.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    
    // Central State Delegate Method
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            state = .off
            foundDevices.removeAll()
        case .poweredOn:
            state = .on
            startScanning()
        case .unsupported:
            state = .error
            foundDevices.removeAll()
        case .unauthorized:
            state = .unauthorized
            foundDevices.removeAll()
        case .unknown:
            state = .error
            foundDevices.removeAll()
        case .resetting:
            state = .on
            foundDevices.removeAll()
        @unknown default:
            state = .error
            foundDevices.removeAll()
        }
    }
 
    // Scanning Delegate Method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !foundDevices.contains(where: {$0.id == peripheral.identifier.uuidString}) {
            foundDevices.append(BlePeripheralModel(peripheral: peripheral, manager: self))
        }
    }
    
    // Connection Delegate Method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Stop scanning for new devices
        stopScanning()
        
        // Find the BLE Peripheral Model
        guard let device = foundDevices.first(where: {$0.id == peripheral.identifier.uuidString}) else {
            return
        }
        
        // Attach the controller to the peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        device.state = .connected
    }
    
    // Service Discovery Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            print(error)
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        // Add the services and discover characteristics
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Characteristic Discovery Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let charicteristics = service.characteristics else {
            return
        }
        
        // Find the BLE Peripheral Model
        guard let blePeripheral = foundDevices.first(where: {$0.id == peripheral.identifier.uuidString}) as? BlePeripheralModel else {
            return
        }
        
        // Add the service characteristics
        for char in charicteristics {
            peripheral.readValue(for: char)
            blePeripheral.addChar(char: char)
        }
    }
    
    // Characteristic Update Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Find the BLE Peripheral Model
        guard let blePeripheral = foundDevices.first(where: {$0.id == peripheral.identifier.uuidString}) as? BlePeripheralModel else {
            return
        }
        
        // Update the associated characteristic
        blePeripheral.update(char: characteristic)
    }
    
    // Device Disconnected Delegate Method
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        // Find the BLE Peripheral Model
        guard let blePeripheral = foundDevices.first(where: {$0.id == peripheral.identifier.uuidString}) as? BlePeripheralModel else {
            return
        }
        
        // Update the associated characteristic
        blePeripheral.state = .disconnected
    }
    
    
}
