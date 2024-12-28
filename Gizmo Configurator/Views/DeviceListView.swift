//
//  DeviceListView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//
import SwiftUI
import UIKit

struct DeviceListView: View {
    @EnvironmentObject var service: PeripheralService
    
    let ViewTitle = Text("Device List")
    
    var body: some View {
        VStack {
            switch service.state {
            case .off:
                ContentUnavailableView("Wireless Turned Off", systemImage: "wifi.slash", description: Text("Wireless connectivity turned off, please turn on in Settings"))
            case .unauthorized:
                ContentUnavailableView("Wireless Connectivity Disabled", systemImage: "wifi.exclamationmark", description: Text("Wireless connectivity disabled, please allow connectivitiy for Gizmo in Settings"))
            case .error:
                ContentUnavailableView("Error", systemImage: "exclamationmark", description: Text("Unknown system error, please close and reopen the app"))
            case .on, .scanning:
                if !service.foundDevices.isEmpty {
                    List($service.foundDevices) { $found in
                        switch found.config {
                        case is NixieConfigModel:
                            NavigationLink(value: found.id)
                            {
                                VStack(alignment: .leading) {
                                    Text(found.config.description)
                                    Text("ID: \(found.id)")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        default:
                            VStack(alignment: .leading) {
                                Text("Unknown Device")
                                Text("ID: \(found.id)")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
                if service.state == .scanning {
                    Spacer()
                    ProgressView(label: {
                        Text("Scanning for devices")
                    })
                }
            }
        }
        .navigationDestination(for: PeripheralModel.ID.self) {id in NixieConfigView(id: id)}
        .navigationTitle(ViewTitle)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button (service.state == .scanning ? "Stop Scanning" : "Scan") {
                    if service.state == .scanning {
                        service.stopScanning()
                    }
                    else {
                        service.startScanning()
                    }
                }
                .disabled(service.state != .scanning && service.state != .on)
            }
        }
        .onDisappear {
            if service.state == .scanning {
                service.stopScanning()
            }
        }
    }
}
