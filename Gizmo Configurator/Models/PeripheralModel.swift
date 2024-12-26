//
//  NixieModel.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import Foundation
import CoreBluetooth

class PeripheralModel: ObservableObject {
    
    // Public Variables
    private var currentConfig: NixieConfigModel
    @Published var updatedConfig: NixieConfigModel
    @Published var populated: Bool
    
    // Initializer
    init() {
        self.currentConfig = NixieConfigModel()
        self.updatedConfig = NixieConfigModel()
        self.populated = false
    }
    
    // Public Properties
    var updated: Bool {
        return (self.currentConfig != self.updatedConfig) && populated
    }
    
    // Public Methods
    func reset() {
        currentConfig = NixieConfigModel()
        updatedConfig = NixieConfigModel()
        populated = false
    }
    
    func update(char: CBCharacteristic) {
        let fullyPopulated = currentConfig.update(characteristic: char)
        if fullyPopulated { updatedConfig.copy(copy: currentConfig) }
        populated = fullyPopulated
    }
    
    func pushValue(char: CBCharacteristic) -> Data? {
        if populated {
            let updatedValue = updatedConfig.pushValue(char: char)
            let currentValue = currentConfig.pushValue(char: char)
            if updatedValue != currentValue {
                return updatedValue
            }
            else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func pushed() {
        currentConfig.copy(copy: updatedConfig)
    }
}
