//
//  AccessoryTranslator.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import Foundation

class AccessoryTranslator {
    static func decode(datumDef: Datum, data: Data) -> Any {
        // Store a local copy so we can mutate it if necessary
        var encoded = data
        var result: Any = 0
        
        // Set the correct default value
        switch datumDef.type {
        case .BOOL:
            result = false
        case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32:
            result = 0
        case .STRING:
            result = ""
        }
        
        // Don't mess with 0 byte data
        guard !data.isEmpty else {
            return result
        }
        
        // Do not decode non-readable values
        guard datumDef.access != .WRITE else {
            return result
        }
        
        // Endian swap if necessary
        if datumDef.endian == .BIG {
            encoded = Data(encoded.reduce([], { [$1] + $0}))
        }
        
        // Decode into container type
        switch datumDef.type {
        case .UINT8:
            result = Int(encoded.withUnsafeBytes { $0.load(as: UInt8.self) })
        case .UINT16:
            result = Int(encoded.withUnsafeBytes { $0.load(as: UInt16.self) })
        case .UINT32:
            result = Int(encoded.withUnsafeBytes { $0.load(as: UInt32.self) })
        case .INT8:
            result = Int(encoded.withUnsafeBytes { $0.load(as: Int8.self) })
        case .INT16:
            result = Int(encoded.withUnsafeBytes { $0.load(as: Int16.self) })
        case .INT32:
            result = Int(encoded.withUnsafeBytes { $0.load(as: Int32.self) })
        case .BOOL:
            result = Int(encoded.withUnsafeBytes{ $0.load(as: UInt8.self) }) == 1
        case .STRING:
            result = String(data: encoded, encoding: .utf8) ?? ""
        }
        
        // Translate as necessary
        switch datumDef.type {
        case .BOOL, .STRING:
            ()
        case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32:
            result = (result as! Int) * datumDef.scalar
            result = (result as! Int) + datumDef.offset
        }
        
        // Return decoded result
        return result
    }
    
    static func encode(datumDef: Datum, data: Any) -> Data {
        // Store a local copy so we can mutate it if necessary
        var decoded = data
        var result: Data = Data()

        // Do not encode non-writable values
        guard datumDef.access != .READ else {
            return result
        }
        
        // Translate as necessary
        switch datumDef.type {
        case .BOOL, .STRING:
            ()
        case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32:
            decoded = (decoded as! Int) - datumDef.offset
            decoded = (decoded as! Int) / datumDef.scalar
        }
        
        // Encode into data type
        switch decoded {
        case is Int:
            switch datumDef.type {
            case .BOOL, .STRING:
                return result
            case .UINT8:
                guard (decoded as! Int) >= 0 else { return result }
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<1) }
            case .UINT16:
                guard (decoded as! Int) >= 0 else { return result }
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<2) }
            case .UINT32:
                guard (decoded as! Int) >= 0 else { return result }
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<4) }
            case .INT8:
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<1) }
            case .INT16:
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<2) }
            case .INT32:
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<4) }
            }
            
        case is Bool:
            switch datumDef.type {
            case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32, .STRING:
                return result
            case .BOOL:
                result = withUnsafeBytes(of: decoded) { Data($0).subdata(in: 0..<1) }
            }
            
        case is String:
            switch datumDef.type {
            case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32, .BOOL:
                return result
            case .STRING:
                result = (decoded as! String).data(using: .utf8) ?? Data()
            }
            
        default:
            result = Data()
        }
        
        // Endian swap if necessary
        if datumDef.endian == .BIG {
            result = Data(result.reduce([], { [$1] + $0 }))
        }
        
        // Return decoded result
        return result
    }
}
