//
//  ConnectionListView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/30/24.
//

import SwiftUI

struct NearbyListView: View {
    @Environment(AccessoryRepository.self) var accessoryRepo
    
    var body: some View {
        VStack {
            switch accessoryRepo.state {
            case .ERROR:
                ContentUnavailableView("Application Error", systemImage: "exclamationmark.triangle.fill", description: Text("Restart the app to continue"))
            case .UNAUTHORIZED:
                ContentUnavailableView("Wireless Permissions Denied", systemImage: "wifi.exclamationmark.circle.fill", description: Text("Grant Gizmo wireless permissions in Settings to continue"))
            case .OFF:
                ContentUnavailableView("Wireless Connections Disabled", systemImage: "wifi.slash", description: Text("Enable wireless connections in Settings to continue"))
            case .ON, .SCANNING:
                if accessoryRepo.accessories.count > 0 {
                    List(accessoryRepo.accessories) { accessory in
                        NavigationLink(value: accessory) {
                            VStack(alignment: .leading) {
                                Text(accessory.name)
                                Text("Type: \(accessory.model.name)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                else {
                    ContentUnavailableView("No Devices Discovered", systemImage: "magnifyingglass.circle.fill", description: Text("No matching devices discovered"))
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Nearby Devices")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if accessoryRepo.state == .SCANNING {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !(accessoryRepo.state == .SCANNING ){
                    Button("Scan") {
                        accessoryRepo.startScanning()
                    }
                    .disabled(accessoryRepo.state == .ERROR || accessoryRepo.state == .UNAUTHORIZED || accessoryRepo.state == .OFF)
                } else {
                    Button("Stop Scanning") {
                        accessoryRepo.stopScanning()
                    }
                }
            }
        }
        .navigationDestination(for: Accessory.self) { accessory in
            NearbyConnectedView(accessory: accessory)
        }
    }
}

//#Preview {
//    let accRepo = AccessoryRepository()
//    let modelRepo = DeviceRepository(modelContext: .init(.init(for: Device.self)), demo: true)
//    NavigationStack{
//        NearbyListView()
//    }
//    .onAppear {
//        accRepo.registerModelRepo(modelRepo: modelRepo)
//    }
//    .environment(accRepo)
//}
