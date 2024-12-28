//
//  PeripheralService.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/27/24.
//

import SwiftUI

@Observable class PeripheralService: NSObject, ObservableObject {
    // Public Variables
    var state: PeripheralServiceState
    var foundDevices: [PeripheralModel]
    
    
    
    // Initializer
    override init() {
        self.state = .off
        self.foundDevices = []
    }
    
    
    
    // Public Methods
    func start() {}
    func registerServices(services: [String]) {}
    func unregisterServices(services: [String]) {}
    func startScanning() {}
    func stopScanning() {}
}

enum PeripheralServiceState: Int {
    case off = 0
    case on = 1
    case scanning = 2
    case unauthorized = 3
    case error = 4
}
