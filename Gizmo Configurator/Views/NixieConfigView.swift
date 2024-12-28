//
//  DeviceSettingsView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/22/24.
//

import SwiftUI
import Foundation

struct NixieConfigView: View {
    var id: PeripheralModel.ID
    @EnvironmentObject var service: PeripheralService
    
    var body: some View {
        // Create config cast to correct subtype
        if let peripheral = service.foundDevices.first(where: {$0.id == id}) {
            let binding = Bindable(peripheral.config as! NixieConfigModel)
            let config = peripheral.config as! NixieConfigModel
            
            // View Definition
            VStack {
                if peripheral.state == .populated {
                    Form {
                        Section (header: Text("Time")) {
                            Picker ("Time Zone", selection: binding.tz) {
                                ForEach(-12...12, id: \.self) {
                                    Text("\($0)")
                                        .tag($0)
                                }
                            }
                            Toggle("DST", isOn: binding.dst)
                        }
                        
                        Section (header: Text("Display")) {
                            Picker ("Mode", selection: binding.mode) {
                                ForEach(NixieConfigModel.Mode.allCases, id: \.rawValue) {
                                    Text("\($0)".capitalized)
                                        .tag($0)
                                }
                            }
                            Picker ("Brightness", selection: binding.brightness) {
                                ForEach(0...100, id: \.self) {
                                    Text(String($0))
                                        .tag($0)
                                }
                            }
                            Toggle("Flashing", isOn: binding.flashing)
                        }
                        
                        Section (header: Text("Wifi")) {
                            HStack{
                                Text("MAC Address")
                                Spacer()
                                Text("\(config.mac.uppercased().inserting(separator: ":", every: 2))")
                            }
                            TextField("SSID", text: binding.ssid)
                            SecureField("Password", text: binding.pw)
                        }
                        
                        HStack {
                            Text("ID")
                            Spacer()
                            Text(peripheral.id)
                                .font(.footnote)
                        }
                    }
                }
                else {
                    ContentUnavailableView("Loading Device Configuration", systemImage: "square.and.arrow.down", description: Text("Loading current configuration from the selected device"))
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Update") {
                        (peripheral as! Configurable).push()
                    }
                    .disabled(!(peripheral.state == .populated) || !(peripheral.updated))
                }
            }
            .navigationTitle("Nixie Clock")
            .onAppear {
                (peripheral as! Configurable).connect()
            }
        }
        else {
            VStack {}
            .navigationTitle("Nixie Clock")
        }
    }
}
