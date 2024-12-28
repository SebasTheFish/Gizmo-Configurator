//
//  NixieModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import Foundation
import CoreBluetooth
import SwiftUI

@Observable class PeripheralModel: Identifiable {
    // Priavte variables
    private var populatedValueIds: Set<String>
    private var currentConfig: any ConfigModel
    
    
    
    // Public Variables
    let id: String
    var config: any ConfigModel
    var state: PeripheralModelState
    
    
    
    // Initializer/Deinitializer
    init(id: String, configModelInit: () -> some ConfigModel) {
        // Private Variables
        self.populatedValueIds = Set()
        self.currentConfig = configModelInit()
        
        // Public Variables
        self.id = id
        self.config = configModelInit()
        self.state = .disconnected
    }
    
    deinit {
        switch state {
        case .disconnected:
            ()
        default:
            state = .disconnected
        }
    }
    
    
    
    // Public Methods
    func setValue(valueId: String, value: Data) {
        // Update the current configuration
        if currentConfig.unpackValue(valueId: valueId, value: value) {
            // Insert into the updated value list
            populatedValueIds.insert(valueId)
        }
        
        // Check if the original config is fully populated
        if populatedValueIds.isSuperset(of: .ValueIds) {
            config.copy(copy: currentConfig)
            state = .populated
        }
    }
    
    func getValue(valueId: String) -> Data? {
        // Get the values from the backing stores
        let updatedValue = config.packValue(valueId: valueId)
        let currentValue = currentConfig.packValue(valueId: valueId)
        
        // Return changes, else return nil
        if updatedValue != currentValue {
            return updatedValue
        }
        else {
            return nil
        }
    }
    
    func resetValues() {
        config.copy(copy: currentConfig)
    }
    
    func updateValues() {
        currentConfig.copy(copy: config)
    }
    
    
    
    // Public Properties
    var updated: Bool {
        currentConfig.hashValue != config.hashValue
    }
    
    
    
    // Type Definitions
    enum PeripheralModelState: Int {
        case disconnected = 0
        case connecting = 1
        case connected = 2
        case populated = 3
    }
}
