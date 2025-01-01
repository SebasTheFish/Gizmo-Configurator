//
//  Accessory.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import SwiftUI
import SwiftData

@Model
class Device: Identifiable, Codable, Hashable {
    // En(De)coding Keys
    enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _serviceIds = "service-ids"
        case _data = "data"
    }
    
    // Accessory definition
    var id: String = UUID().uuidString
    var name: String
    var serviceIds: [String]
    var data: [DatumGroup]
    
    // Initializers
    init(name: String, serviceIds: [String] = [], data: [DatumGroup] = []) {
        self.name = name
        self.serviceIds = serviceIds
        self.data = data
    }
    
    // Public Functions
    func removeService(idx: Int) {
        serviceIds.remove(at: idx)
    }
    
    func addService(serviceId: String) {
        serviceIds.append(serviceId)
    }
    
    func removeGroup(groupId: String) {
        if let idx = data.firstIndex(where: {$0.id == groupId}) {
            data.remove(at: idx)
        }
    }
    
    func addGroup(group: DatumGroup) {
        data.append(group)
    }
    
    func populated(keys: [String]) -> Bool{
        var otherKeys = keys.map({ $0 })
        var localKeys: [String] = []
        
        
        // Grab all keys
        for group in data {
            for datum in group.data {
                if datum.access != .WRITE {
                    localKeys.append(datum.uuid)
                }
            }
        }
        
        // Sort the keys
        localKeys.sort()
        otherKeys.sort()
        
        // Do the comparison
        return localKeys.count == otherKeys.count && localKeys.contains(otherKeys)
    }
    
    // Conformance Functions
    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.name == rhs.name && lhs.serviceIds == rhs.serviceIds && lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: ._name)
        serviceIds = try values.decode([String].self, forKey: ._serviceIds)
        data = try values.decode([DatumGroup].self, forKey: ._data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: ._name)
        try container.encode(serviceIds, forKey: ._serviceIds)
        try container.encode(data, forKey: ._data)
    }
}
