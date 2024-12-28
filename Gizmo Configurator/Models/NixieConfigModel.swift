//
//  NixieConfigModel.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/23/24.
//

import CoreBluetooth
import SwiftUI

// Internal Definitions
@Observable class NixieConfigModel: ConfigModel {
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

    // Protocol Requirements
    var description: String
    
    
    
    // Initializers
    init() {
        self.mac = "00:00:00:00:00:00"
        self.ssid = ""
        self.pw = ""
        
        self.dst = false
        self.tz = 0
        
        self.flashing = true
        self.brightness = 50
        
        self.mode = .time
        
        self.description = "Nixie Clock"
    }
    
    
    
    // Methods
    func unpackValue(valueId: String, value: Data) -> Bool {
        // Unpack the data
        switch valueId {
        case NixieUUIDs.BleWifiMacCharUuid:
            self.mac = String(data: value, encoding: .utf8) ?? ""
        case NixieUUIDs.BleWifiSsidCharUuid:
            self.ssid = String(data: value, encoding: .utf8) ?? ""
        case NixieUUIDs.BleTimeDstCharUuid:
            self.dst = Int(value.withUnsafeBytes { $0.load(as: UInt8.self) }) == 1
        case NixieUUIDs.BleTimeZoneCharUuid:
            self.tz = Int(value.withUnsafeBytes { $0.load(as: UInt8.self) }) - 12
        case NixieUUIDs.BleDispFlashCharUuid:
            self.flashing = Int(value.withUnsafeBytes { $0.load(as: UInt8.self) }) == 1
        case NixieUUIDs.BleDispBrightCharUuid:
            self.brightness = Int(value.withUnsafeBytes { $0.load(as: UInt8.self) })
        case NixieUUIDs.BleGenModeCharUuid:
            self.mode = Mode(rawValue: Int(value.withUnsafeBytes { $0.load(as: UInt8.self) }))!
        default:
            print("Unknown Characteristic")
            return false
        }
        return true
    }
    
    func packValue(valueId: String) -> Data? {
        // Pack the data
        switch valueId {
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
    
    func copy(copy: any ConfigModel) {
        if let cp = copy as? NixieConfigModel {
            self.mac = cp.mac
            self.ssid = cp.ssid
            self.pw = cp.pw
            
            self.dst = cp.dst
            self.tz = cp.tz
            
            self.flashing = cp.flashing
            self.brightness = cp.brightness
            
            self.mode = cp.mode
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(ssid) + String(pw) + String(dst) + String(tz) + String(flashing) + String(brightness) + String(mode.rawValue))
    }
    
    static func == (lhs: NixieConfigModel, rhs: NixieConfigModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    
    
    // Public Type Defintions
    enum Mode: Int, CaseIterable {
        case time = 0
        case date = 1
        case calendar = 2
    }
    
    
    
    // Static Values
    static let ValueIds: [String] = [
        NixieUUIDs.BleWifiMacCharUuid,
        NixieUUIDs.BleWifiSsidCharUuid,
        NixieUUIDs.BleTimeDstCharUuid,
        NixieUUIDs.BleTimeZoneCharUuid,
        NixieUUIDs.BleDispFlashCharUuid,
        NixieUUIDs.BleDispBrightCharUuid,
        NixieUUIDs.BleGenModeCharUuid
    ]
    
    static let ServiceIds: [String] = [
        NixieUUIDs.BleWifiSvcUuid,
        NixieUUIDs.BleTimeSvcUuid,
        NixieUUIDs.BleDispSvcUuid,
        NixieUUIDs.BleGenSvcUuid
    ]
    
    private struct NixieUUIDs {
        // BLE Wifi Config Service
        static let BleWifiSvcUuid =         "185C"
        static let BleWifiMacCharUuid =     "2AF5"
        static let BleWifiSsidCharUuid =    "2AF6"
        static let BleWifiPwCharUuid =      "2AF7"
        
        // BLE Time Config Service
        static let BleTimeSvcUuid =         "185D"
        static let BleTimeZoneCharUuid =    "2AF9"
        static let BleTimeDstCharUuid =     "2AE2"
        
        // BLE Display Config Service
        static let BleDispSvcUuid =         "185E"
        static let BleDispBrightCharUuid =  "2AFA"
        static let BleDispFlashCharUuid =   "2AE3"
        
        // BLE General Config Service
        static let BleGenSvcUuid =          "185F"
        static let BleGenModeCharUuid =     "2AFB"
        static let BleGenResetCharUuid =    "2AE4"
    }
}
