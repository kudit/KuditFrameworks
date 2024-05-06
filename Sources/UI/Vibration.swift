//
//  Vibration.swift
//
//
//  Created by Ben Ku on 10/5/23.
//

#if canImport(AudioToolbox) // not supported by watchOS
import AudioToolbox
#endif
//#if canImport(CoreAudioTypes) // supported by watchOS
//import CoreAudioTypes
//#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public enum Vibration: CaseIterable {
    case system
    case heavy
    case light
    case medium
    case rigid
    case soft
    
    private func unsupportedVibrate() {
        debug("*VIBRATE* (\(self) - Unable to vibrate!)", level: .NOTICE)
    }
    
    public func systemVibrate() -> Bool {
#if canImport(AudioToolbox)
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        return true
#else
        return false
#endif
    }
    
    #if canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))
    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .system:
                nil
        case .heavy:
                .heavy
        case .light:
                .light
        case .medium:
                .medium
        case .rigid:
                .rigid
        case .soft:
                .soft
        }
    }
    #endif
    /// impact feedback generator only available on iOS, and macCatalyst (perhaps for trackpad?)
    public func impactVibrate() -> Bool {
#if canImport(UIKit) && (os(iOS) || targetEnvironment(macCatalyst))
        guard let style = feedbackStyle else {
            return systemVibrate()
        }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        return true
#else
        return false
#endif
    }
    
#if canImport(WatchKit)
    var watchHapticType: WKHapticType {
        switch self {
        case .system:
            .notification
        case .heavy:
            .failure
        case .light:
            .click
        case .medium:
            .start
        case .rigid:
            .retry
        case .soft:
            .success
        }
    }
#endif
    public func watchVibrate() -> Bool {
#if canImport(WatchKit)
        WKInterfaceDevice.current().play(watchHapticType)
        return true
#else
        return false
#endif        
    }
    
    public func vibrate() {
        guard !watchVibrate() else {
            return // success
        }
        guard !impactVibrate() else {
            return // success
        }
        guard !systemVibrate() else {
            return // success
        }
        unsupportedVibrate()
    }
}

#if canImport(SwiftUI)
import SwiftUI

public struct VibrationTestsView: View {
    public init() {}
    public var body: some View {
        VStack {
            ForEach(Vibration.allCases, id: \.self) { vibration in
                Button(String(describing: vibration)) {
                    vibration.vibrate()
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview("Vibration") {
    VibrationTestsView()
}

#endif
