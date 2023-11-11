#if canImport(UIKit) && os(iOS)
//
//  DeviceRotation.swift
//  Shout It
//
//  Created by Ben Ku on 9/29/23.
//

import SwiftUI 

// Our custom view modifier to track rotation and
// call our action
public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
        
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
#endif
