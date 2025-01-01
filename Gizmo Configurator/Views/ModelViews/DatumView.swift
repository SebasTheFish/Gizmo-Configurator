//
//  DatumDetailsView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import SwiftUI

struct DatumView: View {
    @Bindable var datum: Datum
    
    var body: some View {
        Form {
            Section("Description") {
                TextField("Name", text: $datum.name)
                TextField("Details", text: $datum.description)
            }
            Section("Encoding") {
                Picker("Data Type", selection: $datum.type) {
                    ForEach(Datum.Encoded.allCases) { encoding in
                        Text(encoding.rawValue)
                            .tag(encoding.rawValue)
                    }
                }
                Picker("Endian", selection: $datum.endian) {
                    ForEach(Datum.Endian.allCases) { endian in
                        Text(endian.rawValue)
                            .tag(endian.rawValue)
                    }
                }
                Picker("Access", selection: $datum.access) {
                    ForEach(Datum.Access.allCases) { access in
                        Text(access.rawValue)
                            .tag(access.rawValue)
                    }
                }
            }
            if (datum.type != Datum.Encoded.BOOL &&  datum.type != Datum.Encoded.STRING) {
                Section("Scaling") {
                    TextField("Offset", value: $datum.offset, formatter: NumFormatter)
                    .keyboardType(.numbersAndPunctuation)
                    TextField("Scalar", value: $datum.scalar, formatter: NumFormatter)
                    .keyboardType(.numbersAndPunctuation)
                }
            }
        }
    }
}

#Preview {
    DatumView(datum: Datum(type: .STRING, uuid: "", name: "MAC"))
}
