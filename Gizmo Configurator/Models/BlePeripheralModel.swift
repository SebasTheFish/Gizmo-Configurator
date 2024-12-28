//
//  PeripheralModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import CoreBluetooth
import SwiftUI

class BlePeripheralModel: PeripheralModel, Configurable {
    // Private Variables
    private let manager: BlePeripheralService
    private let peripheral: CBPeripheral
    private var characteristics: Set<CBCharacteristic>
    
    
    
    // Initializer/Deinitializer
    init(peripheral: CBPeripheral, manager: BlePeripheralService) {
        self.manager = manager
        self.peripheral = peripheral
        self.characteristics = Set()
        super.init(id: peripheral.identifier.uuidString, configModelInit: NixieConfigModel.init)
    }
    
    deinit {
        switch state {
        case .disconnected:
            ()
        default:
            manager.disconnect(peripheral: peripheral)
        }
    }
    
    
    
    // Connection Method Overrides
    func connect() {
        manager.connect(peripheral: peripheral)
    }

    func disconnect() {
        manager.disconnect(peripheral: peripheral)
    }
    
    func push() {
        // Write all the characteristics
        for char in characteristics {
            if let data = getValue(valueId: char.uuid.uuidString) {
                peripheral.writeValue(data, for: char, type: .withResponse)
            }
        }
        updateValues()
    }
    
    
    
    // Manager methods
    func addChar(char: CBCharacteristic) {
        characteristics.insert(char)
    }
    
    func update(char: CBCharacteristic) {
        if let value = char.value {
            setValue(valueId: char.uuid.uuidString, value: value)
        }
    }
}
