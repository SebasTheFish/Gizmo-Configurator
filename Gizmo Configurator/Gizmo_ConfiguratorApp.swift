//
//  Gizmo_ConfiguratorApp.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import SwiftUI
import SwiftData

@main
struct Gizmo_ConfiguratorApp: App {
    @State private var modelRepo: DeviceRepository
    @State private var accessoryRepo: AccessoryRepository
    let container: ModelContainer
    
    init() {
        // Initialize the Device persistant storage
        do { container = try ModelContainer(for: Device.self) }
        catch { fatalError("Failed to create ModelContainer") }
        
        // Create the application repositories
        modelRepo = DeviceRepository(modelContext: container.mainContext)
        accessoryRepo = AccessoryRepository()
        accessoryRepo.registerModelRepo(modelRepo: modelRepo)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(modelRepo)
        .environment(accessoryRepo)
    }
}
