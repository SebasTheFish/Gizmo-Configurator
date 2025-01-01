//
//  ModelRepository.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/28/24.
//

import Foundation
import SwiftUI
import SwiftData

@Observable class DeviceRepository {
    // Private Variables
    private var storage: DeviceStorage
    
    // Semi-Private Variables
    private(set) public var modelLookupCache: [[String]: Device]
    private(set) public var modelSearchServices: [String]
    private(set) public var models: [Device]
    
    // Initializer
    init(modelContext: ModelContext) {
        self.storage = DeviceStorage(modelContext: modelContext)
        self.modelLookupCache = [:]
        self.modelSearchServices = []
        self.models = []
        
        // Pull from persistant storage
        self.models = self.storage.fetchDevices()
        self.resetLookupCache()
        self.resetSearchServices()
    }
    
    // Private Functions
    func resetLookupCache() {
        modelLookupCache.removeAll()
        for model in models {
            modelLookupCache[model.serviceIds] = model
        }
    }
    
    func resetSearchServices() {
        modelSearchServices.removeAll()
        for model in models {
            for service in model.serviceIds {
                modelSearchServices.append(service)
            }
        }
    }
    
    // Public Functions
    func registerModel(model: Device) {
        // Add the model to the list
        models.append(model)
        storage.addDevice(device: model)

        // Add the new services in the search list
        withObservationTracking({
                for service in model.serviceIds {
                    self.modelSearchServices.append(service)
                }
            },
            token: { model.id },
            willChange: { },
            didChange: { self.resetSearchServices() }
        )
        
        // Add the new service list to the lookup cache
        withObservationTracking({
                self.modelLookupCache[model.serviceIds] = model
            },
            token: { model.id },
            willChange: { },
            didChange: { self.resetLookupCache() }
        )
    }
    
    func unregisterModel(model: Device) {
        storage.removeDevice(device: model)
        if let idx = models.firstIndex(of: model) {
            models.remove(at: idx)
            resetLookupCache()
            resetSearchServices()
        }
    }
    
    // Example Data
    static let modelsExample: [Device] = [
        Device(
            name: "Nixie Clock",
            serviceIds: ServiceIds,
            data: [
                DatumGroup(name: "Network", position: 0, data: [
                    Datum(type: .STRING, endian: .LITTLE, access: .READ, uuid: NixieUUIDs.BleWifiMacCharUuid, name: "MAC", position: 0),
                    Datum(type: .STRING, endian: .LITTLE, access: .READ_WRITE, uuid: NixieUUIDs.BleWifiSsidCharUuid, name: "SSID", position: 1),
                    Datum(type: .STRING, endian: .LITTLE, access: .WRITE, uuid: NixieUUIDs.BleWifiPwCharUuid, name: "Password", position: 2),
                ]),
                DatumGroup(name: "Time", position: 1, data: [
                    Datum(type: .BOOL, endian: .LITTLE, access: .READ_WRITE, uuid: NixieUUIDs.BleTimeDstCharUuid, name: "DST", position: 0),
                    Datum(type: .INT8, endian: .LITTLE, access: .READ_WRITE, uuid: NixieUUIDs.BleTimeZoneCharUuid, name: "Time Zone", position: 1, offset: -12)
                ])
            ]
        )
    ]
}
    
// Static Values
let ValueIds: [String] = [
        NixieUUIDs.BleWifiMacCharUuid,
        NixieUUIDs.BleWifiSsidCharUuid,
        NixieUUIDs.BleTimeDstCharUuid,
        NixieUUIDs.BleTimeZoneCharUuid,
        NixieUUIDs.BleDispFlashCharUuid,
        NixieUUIDs.BleDispBrightCharUuid,
        NixieUUIDs.BleGenModeCharUuid
    ]
    
let ServiceIds: [String] = [
        NixieUUIDs.BleWifiSvcUuid,
        NixieUUIDs.BleTimeSvcUuid,
        NixieUUIDs.BleDispSvcUuid,
        NixieUUIDs.BleGenSvcUuid
    ]
    
struct NixieUUIDs {
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
