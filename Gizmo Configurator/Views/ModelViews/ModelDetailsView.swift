//
//  ModelDetailsView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import SwiftUI

struct ModelDetailsView: View {
    @Bindable var model: Device
    @State var addDatumGroup: Device? = nil
    
    var body: some View {
        Form {
            Section("Description") {
                TextField("Device Name", text: $model.name)
            }
            
            Section("Parameter Groups") {
                ForEach(model.data.sorted(by: {$0.position < $1.position})) { group in
                    NavigationLink(value: group) {
                        Text(group.name)
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            model.removeGroup(groupId: group.id)
                        }
                    }
                }
            }
            
            Section("Advertised Services") {
                ForEach(Array(zip(model.serviceIds.indices, $model.serviceIds)), id: \.0) { idx, $id in
                    TextField("Service ID", text: $id)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            model.removeService(idx: idx)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Add Group") {
                        addDatumGroup = model
                    }
                    Button("Add Service") {
                        model.addService(serviceId: "")
                    }
                } label: {
                    Label("", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: .constant(addDatumGroup != nil)) {
            GroupAddView(model: $addDatumGroup)
        }
    }
}

#Preview {
    NavigationStack {
        ModelDetailsView(model: DeviceRepository.modelsExample[0])
    }
}
