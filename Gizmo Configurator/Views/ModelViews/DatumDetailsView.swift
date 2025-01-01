//
//  ModelAddDatumView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/29/24.
//

import SwiftUI

struct DatumDetailsView: View {
    @Bindable var datum: Datum
    
    var body: some View {
        DatumView(datum: datum)
        .navigationTitle("Parameter Details")
    }
}

#Preview {
    DatumDetailsView(datum: DeviceRepository.modelsExample[0].data[0].data[0])
}
