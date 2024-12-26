//
//  Ble.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import CoreBluetooth

class BleService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    // Public Variables
    @Published var on: Bool
    @Published var scanning: Bool
    @Published var error: Bool
    @Published var foundDevices: [BlePeripheralModel]
    
    // Private Variables
    private var centralMngr: CBCentralManager?
    private var services: [CBUUID]
    
    // Initializer
    override init() {
        // Status Variables
        self.on = false
        self.scanning = false
        self.error = false
        // Peripheral Variables
        self.foundDevices = []
        // Reference to CB Manager
        self.centralMngr = nil
        self.services = []
    }
    
    // Public Methods
    func startBle() {
        // Start the Core Bluetooth Central
        self.centralMngr = CBCentralManager(delegate: self, queue: nil)
    }
    
    func registerServices(services: [CBUUID]) {
        self.services.append(contentsOf: services)
    }
    
    func unregisterServices(services: [CBUUID]) {
        for service in services {
            if let idx = self.services.firstIndex(of: service) {
                self.services.remove(at:idx)
            }
        }
    }
    
    func startScanning() {
        // Start scanning for devices
        centralMngr?.scanForPeripherals(withServices: services)
        scanning = true
    }
    
    func stopScanning() {
        // Stop Scanning
        centralMngr?.stopScan()
        scanning = false
    }
    
    func connect(peripheral: CBPeripheral) {
        centralMngr?.connect(peripheral, options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        centralMngr?.cancelPeripheralConnection(peripheral)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            on = false
            scanning = false
            foundDevices.removeAll()
        case .poweredOn:
            on = true
            startScanning()
        case .unsupported:
            error = true
            foundDevices.removeAll()
        case .unauthorized:
            error = true
            foundDevices.removeAll()
        case .unknown:
            error = true
            foundDevices.removeAll()
        case .resetting:
            on = false
            foundDevices.removeAll()
        @unknown default:
            error = true
            foundDevices.removeAll()
        }
    }
 
    // Scanning Delegate Method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !foundDevices.contains(where: {$0.id == peripheral.identifier}) {
            foundDevices.append(BlePeripheralModel(peripheral: peripheral, manager: self))
        }
    }
    
    // Connection Delegate Method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Stop scanning for new devices
        stopScanning()
        
        // Find the BLE Peripheral Model
        guard foundDevices.first(where: {$0.id == peripheral.identifier}) != nil else {
            return
        }
        
        // Attach the controller to the peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
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
        guard let blePeripheral = foundDevices.first(where: {$0.id == peripheral.identifier}) else {
            return
        }
        
        // Add the service characteristics
        for char in charicteristics {
            peripheral.readValue(for: char)
            blePeripheral.addCharacteristic(char: char)
        }
    }
    
    // Characteristic Update Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Find the BLE Peripheral Model
        guard let blePeripheral = foundDevices.first(where: {$0.id == peripheral.identifier}) else {
            return
        }
        
        // Update the associated characteristic
        blePeripheral.update(char: characteristic)
    }
    
}
