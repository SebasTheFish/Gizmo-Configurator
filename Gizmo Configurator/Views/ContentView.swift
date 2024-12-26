//
//  ContentView.swift
//  Nixie Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ble: BleService = BleService()
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
                DeviceListView(ble: ble)
            }
        }
        .onAppear {
            ble.registerServices(services: NixieConfigModel.Services)
            ble.startBle()
        }
    }
}

#Preview {
    ContentView()
}
