//
//  ModelAddView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/29/24.
//

import SwiftUI

struct ModelAddView: View {
    @Environment(AppPaths.self) var appPath
    var modelRepo: DeviceRepository
    @Binding var isPresented: Bool
    @State var model: Device = Device(name: "")
    
    var body: some View {
        NavigationStack{
            Form {
                TextField("Device Name", text: $model.name)
            }
            .navigationTitle("New Device")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelRepo.registerModel(model: model)
                        appPath.models.append(model)
                        isPresented = false
                    }
                    .disabled(model.name == "")
                }
            }
            .onAppear {
                model = Device(name: "")
            }
        }
    }
}

//#Preview {
//    ModelAddView(modelRepo: DeviceRepository(modelContext: .init(.init(for: Device.self)), demo: true), isPresented: .constant(true))
//        .environment(AppPaths())
//}
