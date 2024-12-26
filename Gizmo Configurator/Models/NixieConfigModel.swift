//
//  NixieConfigModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/23/24.
//

import CoreBluetooth

// Internal Definitions
class NixieConfigModel: Equatable {
    // Private Variables
    var updated: Set<CBUUID>
    
    // Wifi Variables
    var mac: String
    var ssid: String
    var pw: String
    
    // Time Variables
    var dst: Bool
    var tz: Int
    
    // Display Variables
    var flashing: Bool
    var brightness: Int
    
    // General Variables
    var mode: Mode
    
    // Initializers
    init() {
        self.updated = Set()
        
        self.mac = "00:00:00:00:00:00"
        self.ssid = ""
        self.pw = ""
        
        self.dst = false
        self.tz = 0
        
        self.flashing = true
        self.brightness = 50
        
        self.mode = .time
    }
    
    // Methods
    func update(characteristic: CBCharacteristic) -> Bool {
        if characteristic.value != nil {
            // Add to the updated set
            updated.insert(characteristic.uuid)
            switch characteristic.uuid {
            case NixieUUIDs.BleWifiMacCharUuid:
                self.mac = String(data: characteristic.value!, encoding: .utf8) ?? ""
            case NixieUUIDs.BleWifiSsidCharUuid:
                self.ssid = String(data: characteristic.value!, encoding: .utf8) ?? ""
            case NixieUUIDs.BleTimeDstCharUuid:
                self.dst = Int(characteristic.value!.withUnsafeBytes { $0.load(as: UInt8.self) }) == 1
            case NixieUUIDs.BleTimeZoneCharUuid:
                self.tz = Int(characteristic.value!.withUnsafeBytes { $0.load(as: UInt8.self) }) - 12
            case NixieUUIDs.BleDispFlashCharUuid:
                self.flashing = Int(characteristic.value!.withUnsafeBytes { $0.load(as: UInt8.self) }) == 1
            case NixieUUIDs.BleDispBrightCharUuid:
                self.brightness = Int(characteristic.value!.withUnsafeBytes { $0.load(as: UInt8.self) })
            case NixieUUIDs.BleGenModeCharUuid:
                self.mode = Mode(rawValue: Int(characteristic.value!.withUnsafeBytes { $0.load(as: UInt8.self) }))!
            default:
                print("Unknown Characteristic")
            }
        }
        
        // Return whether the whole object has been updated
        return updated.isSuperset(of: Self.chars)
    }
    
    func copy(copy: NixieConfigModel) {
        self.updated = copy.updated
        
        self.mac = copy.mac
        self.ssid = copy.ssid
        self.pw = copy.pw
        
        self.dst = copy.dst
        self.tz = copy.tz
        
        self.flashing = copy.flashing
        self.brightness = copy.brightness
        
        self.mode = copy.mode
    }
    
    func pushValue(char: CBCharacteristic) -> Data? {
        switch char.uuid {
        case NixieUUIDs.BleWifiPwCharUuid:
            return self.pw.data(using: .utf8)
        case NixieUUIDs.BleWifiSsidCharUuid:
            return self.ssid.data(using: .utf8)
        case NixieUUIDs.BleTimeDstCharUuid:
            return withUnsafeBytes(of: self.dst) { Data($0).subdata(in: 0..<1) }
        case NixieUUIDs.BleTimeZoneCharUuid:
            return withUnsafeBytes(of: (self.tz + 12)) { Data($0).subdata(in: 0..<1) }
        case NixieUUIDs.BleDispFlashCharUuid:
            return withUnsafeBytes(of: self.flashing) { Data($0).subdata(in: 0..<1) }
        case NixieUUIDs.BleDispBrightCharUuid:
            return withUnsafeBytes(of: self.brightness) { Data($0).subdata(in: 0..<1) }
        case NixieUUIDs.BleGenModeCharUuid:
            return withUnsafeBytes(of: self.mode) { Data($0).subdata(in: 0..<1) }
        default:
            return nil
        }
    }
    
    static func == (lhs: NixieConfigModel, rhs: NixieConfigModel) -> Bool {
        lhs.mac == rhs.mac && lhs.ssid == rhs.ssid && lhs.pw == rhs.pw && lhs.dst == rhs.dst && lhs.tz == rhs.tz && lhs.flashing == rhs.flashing && lhs.brightness == rhs.brightness && lhs.mode == rhs.mode
    }
    
    // Static Assets
    static private let chars = [
        NixieUUIDs.BleWifiMacCharUuid,
        NixieUUIDs.BleWifiSsidCharUuid,
        NixieUUIDs.BleTimeDstCharUuid,
        NixieUUIDs.BleTimeZoneCharUuid,
        NixieUUIDs.BleDispFlashCharUuid,
        NixieUUIDs.BleDispBrightCharUuid,
        NixieUUIDs.BleGenModeCharUuid
    ]
    
    static let Services = [
        NixieUUIDs.BleWifiSvcUuid,
        NixieUUIDs.BleTimeSvcUuid,
        NixieUUIDs.BleDispSvcUuid,
        NixieUUIDs.BleGenSvcUuid
    ]
    
    // Private Definitions
    enum Mode: Int, CaseIterable {
        case time = 0
        case date = 1
        case calendar = 2
    }
}

struct NixieUUIDs {
    // BLE Wifi Config Service
    static let BleWifiSvcUuid =         CBUUID(string: "185C")
    static let BleWifiMacCharUuid =     CBUUID(string: "2AF5")
    static let BleWifiSsidCharUuid =    CBUUID(string: "2AF6")
    static let BleWifiPwCharUuid =      CBUUID(string: "2AF7")
    
    // BLE Time Config Service
    static let BleTimeSvcUuid =         CBUUID(string: "185D")
    static let BleTimeZoneCharUuid =    CBUUID(string: "2AF9")
    static let BleTimeDstCharUuid =     CBUUID(string: "2AE2")
    
    // BLE Display Config Service
    static let BleDispSvcUuid =         CBUUID(string: "185E")
    static let BleDispBrightCharUuid =  CBUUID(string: "2AFA")
    static let BleDispFlashCharUuid =   CBUUID(string: "2AE3")
    
    // BLE General Config Service
    static let BleGenSvcUuid =          CBUUID(string: "185F")
    static let BleGenModeCharUuid =     CBUUID(string: "2AFB")
    static let BleGenResetCharUuid =    CBUUID(string: "2AE4")
}
