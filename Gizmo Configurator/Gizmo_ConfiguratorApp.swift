//
//  Gizmo_ConfiguratorApp.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import SwiftUI

@main
struct Gizmo_ConfiguratorApp: App {
    @State private var peripheralService: PeripheralService = BlePeripheralService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(peripheralService)
    }
}
