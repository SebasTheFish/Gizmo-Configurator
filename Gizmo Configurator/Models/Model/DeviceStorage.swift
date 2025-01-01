//
//  DeviceStorage.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 1/1/25.
//

import SwiftData

class DeviceStorage {
    var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchDevices() -> [Device] {
        do {
            let descriptor = FetchDescriptor<Device>()
            return try modelContext.fetch(descriptor)
        }
        catch {
            print("Fetch failed")
            return []
        }
    }
    
    func addDevice(device: Device) {
        modelContext.insert(device)
    }
    
    func removeDevice(device: Device) {
        modelContext.delete(device)
    }
}
