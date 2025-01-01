//
//  NearbyConnectedView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

struct NearbyConnectedView: View {
    @Bindable var accessory: Accessory
    
    var body: some View {
        VStack {
            if accessory.state == .populated {
                Form {
                    ForEach(accessory.model.data) { group in
                        Section(group.name) {
                            ForEach(group.data) { datum in
                                NearbyParameterView(accessory: accessory, datum: datum)
                            }
                        }
                    }
                    Section("Identity") {
                        HStack{
                            Text("Type")
                            Spacer()
                            Text("\(accessory.model.name)")
                        }
                        HStack{
                            Text("ID")
                            Spacer()
                            Text("\(accessory.id)")
                            .font(.caption)
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("Downloading Data", systemImage: "square.and.arrow.down.fill", description: Text("Getting configuration data from the device"))
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationTitle(accessory.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Update") {
                    accessory.pushConfig()
                }
                .disabled(!accessory.modified)
            }
        }
        .onAppear {
            accessory.connect()
        }
        .onDisappear {
            accessory.disconnect()
            accessory.resetConfig()
        }
    }
}

#Preview {
    NavigationStack{
        NearbyConnectedView(accessory: Accessory(id: "test", name: "Test", interface: .DEMO, repo: AccessoryRepository(), model: DeviceRepository.modelsExample[0]))
    }
}
