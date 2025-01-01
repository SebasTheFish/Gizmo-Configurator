//
//  NumFormatter.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

let NumFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
