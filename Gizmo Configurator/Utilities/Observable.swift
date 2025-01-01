//
//  Observable.swift
//  Gizmo Configurator
//
// https://augmentedcode.io

import SwiftUI

func withObservationTracking(
    _ apply: @escaping () -> Void,
    token: @escaping () -> String?,
    willChange: (@Sendable () -> Void)? = nil,
    didChange: @escaping @Sendable () -> Void
) {
    withObservationTracking(apply) {
        guard token() != nil else { return }
        willChange?()
        RunLoop.current.perform {
            didChange()
            withObservationTracking(
                apply,
                token: token,
                willChange: willChange,
                didChange: didChange
            )
        }
    }
}
