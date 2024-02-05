//
//  Vibration.swift
//
//
//  Created by Ben Ku on 10/5/23.
//
#if !os(tvOS) // none of this is relevant for tvOS except maybe an alert sound.  TODO?

#if canImport(AudioToolbox) && canImport(CoreAudioTypes)
import AudioToolbox
import CoreAudioTypes
#endif
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
	public func vibrate() {
#if canImport(UIKit) && !os(visionOS)
		switch self {
		case .system:
			#if canImport(AudioToolbox)
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
			#elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.notification)
			#endif
		case .heavy:
            #if canImport(AudioToolbox)
			let generator = UIImpactFeedbackGenerator(style: .heavy)
			generator.impactOccurred()
            #elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.failure)
            #endif
		case .light:
            #if canImport(AudioToolbox)
			let generator = UIImpactFeedbackGenerator(style: .light)
			generator.impactOccurred()
            #elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.click)
            #endif
		case .medium:
            #if canImport(AudioToolbox)
			let generator = UIImpactFeedbackGenerator(style: .medium)
			generator.impactOccurred()
            #elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.start)
            #endif
		case .rigid:
            #if canImport(AudioToolbox)
			let generator = UIImpactFeedbackGenerator(style: .soft)
			generator.impactOccurred()
            #elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.retry)
            #endif
		case .soft:
            #if canImport(AudioToolbox)
			let generator = UIImpactFeedbackGenerator(style: .soft)
			generator.impactOccurred()
            #elseif canImport(WatchKit)
			WKInterfaceDevice.current().play(.success)
            #endif
		}
#else
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
#endif
	}
}
#endif
