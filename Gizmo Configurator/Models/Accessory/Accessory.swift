//
//  Accessory.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import Foundation
import CoreBluetooth

@Observable class Accessory: Identifiable, Hashable {
    // Type Definitions
    enum Interface {
        case DEMO
        case BLE(CBPeripheral, CBCentralManager)
    }
    
    enum State {
        case disconnected
        case connected
        case populated
    }
    
    // Private Variables
    private var currentConfig: [String: Data]
    private let repo: AccessoryRepository
    
    // Public Properties
    let id: String
    let name: String
    let interface: Interface
    let model: Device
    private(set) var state: State
    var config: [String: Data]
    
    // Computed Properties
    var modified: Bool { return config != currentConfig && state == .populated}
    var parameters: [Datum] {
        return model.data.flatMap({ $0.data.map({ $0 }) })
    }
    
    // Initializer
    init (id: String, name: String, interface: Interface, repo: AccessoryRepository, model: Device) {
        self.id = id
        self.name = name
        self.interface = interface
        self.repo = repo
        self.currentConfig = [:]
        self.model = model
        self.state = .disconnected
        
        self.config = [:]
    }
    
    // Public Config Methods
    func updateConfig(key: String, data: Data) {
        currentConfig[key] = data
        if model.populated(keys: currentConfig.keys.map({ $0 })) {
            resetConfig()
            state = .populated
        }
    }
    
    func pushConfig() {
        if state == .populated{
            // Push the updated value
            repo.pushUpdate(accessory: self)
         
            // Update the current config
            currentConfig = config.mapValues({$0})
        }
    }
    
    func resetConfig() {
        // Make a deep copy
        config = currentConfig.mapValues({$0})
    }
    
    // Public Connection Methods
    func connect() {
        switch self.interface {
        case .DEMO:
            print("Connected")
            state = .connected
        case let .BLE(peripheral, manager):
            manager.connect(peripheral)
            state = .connected
        }
    }
    
    func disconnect() {
        switch self.interface {
        case .DEMO:
            state = .disconnected
            print("Disconnected")
        case let .BLE(peripheral, manager):
            state = .disconnected
            manager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // Protocol Conformance
    static func == (lhs: Accessory, rhs: Accessory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
