//
//  DataModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import Foundation

@Observable class Datum: Identifiable, Codable, Hashable {
    // Type Definitions
    enum Encoded: String, Identifiable, Codable, CaseIterable {
        case UINT8 = "Unsigned Integer 8"
        case UINT16 = "Unsigned Integer 16"
        case UINT32 = "Unsigned Integer 32"
        case INT8 = "Integer 8"
        case INT16 = "Integer 16"
        case INT32 = "Integer 32"
        case BOOL = "Boolean"
        case STRING = "String"
        
        var id: Self { self }
    }
    
    enum Endian: String, Identifiable, Codable, CaseIterable {
        case LITTLE = "Little"
        case BIG = "Big"
        
        var id: Self { self }
    }
    
    enum Access: String, Identifiable, Codable, CaseIterable {
        case READ = "Read"
        case WRITE = "Write"
        case READ_WRITE = "Read/Write"
        
        var id: Self { self }
    }
    
    // En(De)coding Keys
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _endian = "endian"
        case _access = "access"
        case _uuid = "uuid"
        case _name = "name"
        case _position = "position"
        case _description = "description"
        case _offset = "offset"
        case _scalar = "scalar"
    }
    
    // Identification Information
    let id: String = UUID().uuidString
    
    // Encoding Information
    var type: Encoded
    var endian: Endian
    var access: Access
    var uuid: String
    
    // Presentation Information
    var name: String
    var position: Int
    var description: String
    
    // Scaling Information
    var offset: Int
    var scalar: Int
    
    init(type: Encoded, endian: Endian = .LITTLE, access: Access = .READ_WRITE, uuid: String, name: String, position: Int = 0, description: String = "", offset: Int = 0, scalar: Int = 1) {
        
        self.type = type
        self.endian = endian
        self.access = access
        self.uuid = uuid
        
        self.name = name
        self.position = position
        self.description = description
        
        self.offset = offset
        self.scalar = scalar
    }
    
    // Protocol Conformance
    static func == (lhs: Datum, rhs: Datum) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type && lhs.endian == rhs.endian && lhs.access == rhs.access && lhs.name == rhs.name && lhs.position == rhs.position && lhs.description == rhs.description && lhs.offset == rhs.offset && lhs.scalar == rhs.scalar
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable class DatumGroup: Identifiable, Codable, Hashable {
    // En(De)coding Keys
    enum CodingKeys: String, CodingKey {
        case _name = "name"
        case _position = "position"
        case _data = "data"
    }
    
    let id: String = UUID().uuidString
    var name: String
    var position: Int
    var data: [Datum]
    
    init(name: String, position: Int = 0, data: [Datum] = []) {
        self.name = name
        self.position = position
        self.data = data
    }
    
    // Public Methods
    func removeDatum(datumId: String) {
        if let idx = data.firstIndex(where: {$0.id == datumId}) {
            data.remove(at: idx)
        }
    }
    
    func addDatum(datum: Datum) {
        data.append(datum)
    }
    
    // Protocol Conformance
    static func == (lhs: DatumGroup, rhs: DatumGroup) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.position == rhs.position && lhs.data == rhs.data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
