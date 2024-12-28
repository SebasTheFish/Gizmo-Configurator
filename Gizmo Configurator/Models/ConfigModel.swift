//
//  ConfigModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/26/24.
//

import Foundation

protocol ConfigModel: Hashable {
    // Public Variables
    var description: String { get }
    
    // Static Variables
    static var ValueIds: [String] { get }
    static var ServiceIds: [String] { get }
    
    // Public Methods
    func unpackValue(valueId: String, value: Data) -> Bool
    func packValue(valueId: String) -> Data?
    func copy(copy: any ConfigModel)
}

protocol Configurable {
    func connect()
    func disconnect()
    func push()
}
