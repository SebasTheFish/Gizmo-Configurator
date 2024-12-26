//
//  PeripheralModel.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import CoreBluetooth

class BlePeripheralModel: ObservableObject, Identifiable {
    private let manager: BleService
    private let peripheral: CBPeripheral
    private var characteristics: Set<CBCharacteristic>
    @Published var model: PeripheralModel
    
    init(peripheral: CBPeripheral, manager: BleService) {
        self.manager = manager
        self.peripheral = peripheral
        self.characteristics = Set()
        self.model = PeripheralModel()
    }
    
    // Methods
    func connect() {
        manager.connect(peripheral: peripheral)
    }

    func disconnect() {
        manager.disconnect(peripheral: peripheral)
        model.reset()
        objectWillChange.send()
    }
    
    func addCharacteristic(char: CBCharacteristic) {
        characteristics.insert(char)
    }
    
    func update(char: CBCharacteristic) {
        model.update(char: char)
        objectWillChange.send()
    }
    
    func push() {
        for char in characteristics {
            if let data = model.pushValue(char: char) {
                peripheral.writeValue(data, for: char, type: .withResponse)
            }
        }
        model.pushed()
        objectWillChange.send()
    }
    
    // Parameters
    var id: UUID {
        return peripheral.identifier
    }
}
