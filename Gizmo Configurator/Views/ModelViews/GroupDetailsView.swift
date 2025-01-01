//
//  GroupDetailsView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

struct GroupDetailsView: View {
    @Bindable var group: DatumGroup
    @State var presentingAddDatum: Bool = false
    
    var body: some View {
        Form {
            Section("Description") {
                TextField("Name", text: $group.name)
            }
            
            Section("Parameters") {
                ForEach(group.data) { datum in
                    NavigationLink(value: datum) {
                        Text(datum.name)
                    }
                }
            }
        }
        .navigationTitle("Group Details")
        .toolbar {
            Button {
                presentingAddDatum = true
            } label: {
                Label("", systemImage: "plus")
            }
        }
        .sheet(isPresented: $presentingAddDatum) {
            DatumAddView(group: group, isPresenting: $presentingAddDatum)
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailsView(group: DatumGroup(name: "Test"))
    }
}
