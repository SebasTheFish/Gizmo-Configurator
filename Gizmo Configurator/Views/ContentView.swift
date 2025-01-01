//
//  ContentView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var appPaths: AppPaths = AppPaths()
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Nearby", systemImage: "wifi.circle") {
                    NavigationStack(path: $appPaths.nearby) {
                        NearbyListView()
                    }
                }
                Tab("Library", systemImage: "list.bullet.rectangle") {
                    NavigationStack(path: $appPaths.models) {
                        ModelListView()
                    }
                }
            }
        }
        .environment(appPaths)
    }
}
//
//#Preview {
//    let modelRepo = DeviceRepository(modelContext: .init(.init(for: Device.self)), demo: true)
//    let accRepo = AccessoryRepository()
//    ContentView()
//        .environment(accRepo)
//        .environment(modelRepo)
//        .onAppear { accRepo.registerModelRepo(modelRepo: modelRepo) }
//}
