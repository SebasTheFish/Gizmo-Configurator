//
//  ModelAddDatumView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/29/24.
//

import SwiftUI

struct DatumAddView: View {
    @Bindable var group: DatumGroup
    @Binding var isPresenting: Bool
    @State var datum: Datum = Datum(type: .BOOL, uuid: "", name: "")
    
    var body: some View {
        NavigationStack {
            DatumView(datum: datum)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresenting = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        group.addDatum(datum: datum)
                        isPresenting = false
                    }
                }
            }
            .navigationTitle("New Paramter")
            .onAppear {
                datum = Datum(type: .BOOL, uuid: "", name: "")
            }
        }
    }
}

#Preview {
    DatumAddView(group: DeviceRepository.modelsExample[0].data[0], isPresenting: .constant(true))
}
