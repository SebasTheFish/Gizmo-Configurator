//
//  DeviceSettingsView.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import SwiftUI
import Foundation

struct NixieConfigView: View {
    @ObservedObject var peripheral: BlePeripheralModel
    
    var body: some View {
        VStack {
            if !peripheral.model.populated {
                ContentUnavailableView("Loading Device Configuration", systemImage: "square.and.arrow.down", description: Text("Loading current configuration from the selected device"))
            }
            else{
                Form {
                    Section (header: Text("Time")) {
                        Picker ("Time Zone", selection: $peripheral.model.updatedConfig.tz) {
                            ForEach(-12...12, id: \.self) {
                                Text("\($0)")
                                    .tag($0)
                            }
                        }
                        Toggle("DST", isOn: $peripheral.model.updatedConfig.dst)
                    }
                    
                    Section (header: Text("Display")) {
                        Picker ("Mode", selection: $peripheral.model.updatedConfig.mode) {
                            ForEach(NixieConfigModel.Mode.allCases, id: \.rawValue) {
                                Text("\($0)".capitalized)
                                    .tag($0)
                            }
                        }
                        Picker ("Brightness", selection: $peripheral.model.updatedConfig.brightness) {
                            ForEach(0...100, id: \.self) {
                                Text(String($0))
                                    .tag($0)
                            }
                        }
                        Toggle("Flashing", isOn: $peripheral.model.updatedConfig.flashing)
                    }
                    
                    Section (header: Text("Wifi")) {
                        HStack{
                            Text("MAC Address")
                            Spacer()
                            Text("\(peripheral.model.updatedConfig.mac.uppercased().inserting(separator: ":", every: 2))")
                        }
                        TextField("SSID", text: $peripheral.model.updatedConfig.ssid)
                        SecureField("Password", text: $peripheral.model.updatedConfig.pw)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Update") {
                    peripheral.push()
                }
                .disabled(!peripheral.model.updated)
            }
        }
        .navigationTitle("Nixie Clock")
        .onAppear {
            peripheral.connect()
        }
        .onDisappear {
            peripheral.disconnect()
        }
    }
}
