//
//  NearbyParamterView.swift
//  Gizmo Configurator
//
//  Created by Sebastian Moruszewicz on 12/31/24.
//

import SwiftUI

struct NearbyParameterView: View {
    @Bindable var accessory: Accessory
    var datum: Datum
    
    var body: some View {
        let boolBinding = Binding<Bool>(get: {
            AccessoryTranslator.decode(datumDef: datum, data: accessory.config[datum.uuid] ?? Data()) as? Bool ?? false
        }, set: {
            accessory.config[datum.uuid] = AccessoryTranslator.encode(datumDef: datum, data: $0)
        })
        let intBinding = Binding<Int>(get: {
            AccessoryTranslator.decode(datumDef: datum, data: accessory.config[datum.uuid] ?? Data()) as? Int ?? 0
        }, set: {
            accessory.config[datum.uuid] = AccessoryTranslator.encode(datumDef: datum, data: $0)
        })
        let strBinding = Binding<String>(get: {
            let data = accessory.config[datum.uuid] ?? Data()
            let string = AccessoryTranslator.decode(datumDef: datum, data: data) as? String
            return string ?? ""
        }, set: {
            accessory.config[datum.uuid] = AccessoryTranslator.encode(datumDef: datum, data: $0)
        })
        
        switch datum.type {
        case .BOOL:
            Toggle(datum.name, isOn: boolBinding)
                .disabled(datum.access == .READ)
        case .UINT8, .UINT16, .UINT32, .INT8, .INT16, .INT32:
            if datum.access != .READ {
                TextField(datum.name, value: intBinding, formatter: NumFormatter)
                .keyboardType(.numbersAndPunctuation)
            }
            else {
                HStack {
                    Text(datum.name)
                    Spacer()
                    Text(String(intBinding.wrappedValue))
                }
            }
        case .STRING:
            if datum.access != .READ {
                TextField(datum.name, text: strBinding)
            }
            else {
                HStack {
                    Text(datum.name)
                    Spacer()
                    Text(String(strBinding.wrappedValue))
                }
            }
        }
    }
}
