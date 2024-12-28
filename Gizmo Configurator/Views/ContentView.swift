//
//  ContentView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var appPath = NavigationPath()
    @EnvironmentObject var service: PeripheralService
    
    var body: some View {
        NavigationStack(path: $appPath) {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
                DeviceListView()
            }
        }
        .onAppear {
            service.registerServices(services: NixieConfigModel.ServiceIds)
            service.start()
        }
        .onChange(of: service.state) {
            switch service.state{
            case .off, .unauthorized, .error:
                (appPath.removeLast(appPath.count))
            default:
                ()
            }
        }
    }
}
