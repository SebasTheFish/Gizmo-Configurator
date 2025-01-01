//
//  GroupAddView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

struct GroupAddView: View {
    @Environment(AppPaths.self) var appPath
    @Binding var model: Device?
    @State var group: DatumGroup = DatumGroup(name: "")
    
    var body: some View {
        NavigationStack{
            Form {
                TextField("Group Name", text: $group.name)
            }
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        model = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let model {
                            model.addGroup(group: group)
                            appPath.models.append(group)
                        }
                        model = nil
                    }
                    .disabled(group.name == "")
                }
            }
            .onAppear {
                group = DatumGroup(name: "")
            }
        }
    }
}

#Preview {
    GroupAddView(model: .constant(Device(name: "")))
        .environment(AppPaths())
}
