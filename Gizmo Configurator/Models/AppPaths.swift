//
//  Path.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

@Observable class AppPaths {
    var nearby: NavigationPath
    var models: NavigationPath
    
    init() {
        self.nearby = NavigationPath()
        self.models = NavigationPath()
    }
}
