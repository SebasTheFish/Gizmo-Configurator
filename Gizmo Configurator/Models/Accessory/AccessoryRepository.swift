//
//  AccessoryRepository.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import Foundation
import CoreBluetooth

@Observable class AccessoryRepository: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Type Definitions
    enum State {
        case OFF
        case ON
        case SCANNING
        case UNAUTHORIZED
        case ERROR
    }
    
    // Private Variables
    private var modelRepo: DeviceRepository?
    private var central: CBCentralManager?
    private var characteristics: [Accessory: [String: CBCharacteristic]]
    
    // Public Variables
    var accessories: [Accessory]
    private(set) var state: State
    
    // Initializer
    override init() {
        self.modelRepo = nil
        self.state = .OFF
        self.accessories = []
        self.characteristics = [:]
        
        // Call the super constructor
        super.init()
        
        // Create the bluetooth service
        self.central = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Public Methods
    func registerModelRepo(modelRepo: DeviceRepository) {
        self.modelRepo = modelRepo
    }
    
    func unregisterModelRepo() {
        self.modelRepo = nil
    }
    
    func startScanning() {
        // Check for a model repository
        guard modelRepo != nil else { return }
        
        // Check for valid state
        guard state  == .ON else { return }
        
        // Update the scanning list
        withObservationTracking({
            self.central?.scanForPeripherals(withServices: self.modelRepo?.modelSearchServices.map({CBUUID(string: $0)}))
        },
        token: {self.state == .SCANNING ? "Token" : nil},
        willChange: {},
        didChange: {
            if self.state == .SCANNING {
                self.accessories.removeAll()
                self.central?.stopScan()
                self.central?.scanForPeripherals(withServices: self.modelRepo?.modelSearchServices.map({CBUUID(string: $0)}))
            }
        })
        
        // Update the service's state
        self.state = .SCANNING
    }
    
    func stopScanning() {
        // Check for a model repository
        guard modelRepo != nil else { return }
        
        // Check that we are actually scanning
        guard state == .SCANNING else { return }
        
        self.central?.stopScan()
        
        // Update the service's state
        self.state = .ON
    }
    
    func pushUpdate(accessory: Accessory) {
        if let chars = characteristics[accessory] {
            for char in chars {
                switch accessory.interface {
                case let .BLE(peripheral, _):
                    if let data = accessory.config[char.key] {
                        if let datum = accessory.parameters.first(where: {$0.uuid == char.key}) {
                            if datum.access != .READ {
                                peripheral.writeValue(data, for: char.value, type: .withResponse)
                            }
                        }
                    }
                default:
                    print("Pushed Key: \(char.key)")
                }
            }
        }
  }
    
    // Central State Delegate Service
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            state = .OFF
            accessories.removeAll()
            characteristics.removeAll()
        case .poweredOn:
            state = .ON
        case .resetting:
            accessories.removeAll()
            characteristics.removeAll()
        case .unauthorized:
            state = .UNAUTHORIZED
            accessories.removeAll()
            characteristics.removeAll()
        default:
            state = .ERROR
            accessories.removeAll()
            characteristics.removeAll()
        }
    }
    
    // Scanning Delegate Method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !accessories.contains(where: {$0.id == peripheral.identifier.uuidString}) {
            let services = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? NSArray)
            let advName = (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            let uuids = services?.compactMap({ ($0 as! CBUUID).uuidString }) ?? []
            if let model = modelRepo?.modelLookupCache[uuids] {
                if !model.serviceIds.isEmpty {
                    accessories.append(Accessory(id: peripheral.identifier.uuidString, name: peripheral.name ?? advName ?? "No Name", interface: .BLE(peripheral, central), repo: self, model: model))
                }
            }
        }
    }
    
    // Connection Delegate Method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Check if the accessory is supported
        guard accessories.first(where: {$0.id == peripheral.identifier.uuidString}) != nil else { return }
        
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
        
        // Check that there are services to reference
        guard let services = peripheral.services else { return }
        
        // Discover characteristics
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Characteristic Discovery Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        // Check if the accessory is supported
        guard let accessory = accessories.first(where: { $0.id == peripheral.identifier.uuidString }) else { return }
        
        // Add the service characteristics
        for char in characteristics {
            // Initialize if necessary
            if self.characteristics[accessory] == nil {
                self.characteristics[accessory] = [:]
            }
            
            // Update chars
            self.characteristics[accessory]![char.uuid.uuidString] = char
            if let parameter = accessory.parameters.first(where: { $0.uuid == char.uuid.uuidString }) {
                if parameter.access != .WRITE {
                    peripheral.readValue(for: char)
                }
            }
        }
    }
    
    
    // Characteristic Update Delegate Method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            print(error)
            return
        }
        
        // Find the Accessory
        guard let accessory = accessories.first(where: { $0.id == peripheral.identifier.uuidString }) else { return }
        
        // Update the accessory config
        if let value = characteristic.value {
            accessory.updateConfig(key: characteristic.uuid.uuidString, data: value)
        }
    }
}
