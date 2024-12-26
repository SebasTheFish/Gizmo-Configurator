//
//  DeviceListView.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//
import SwiftUI
import UIKit

struct DeviceListView: View {
    @ObservedObject var ble: BleService
    
    let ViewTitle = Text("Device List")
    
    var body: some View {
        VStack {
            if !ble.foundDevices.isEmpty {
                List(ble.foundDevices, id: \.id) { found in
                    NavigationLink {
                        NixieConfigView(peripheral: found)
                    } label: {
                        VStack(alignment: .leading) {
                            Text("Nixie Clock")
                            Text("ID: \(found.id)")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            }
            if ble.scanning {
                Spacer()
                ProgressView(label: {
                    Text("Scanning for devices")
                })
            }
        }
        .navigationTitle(ViewTitle)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button (ble.scanning ? "Stop Scanning" : "Scan") {
                    if ble.scanning {
                        ble.stopScanning()
                    }
                    else {
                        ble.startScanning()
                    }
                }
                .disabled(!ble.on)
            }
        }
        .onDisappear {
            if ble.on && ble.scanning{
                ble.stopScanning()
            }
        }
    }
}
