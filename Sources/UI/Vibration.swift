//
//  Vibration.swift
//
//
//  Created by Ben Ku on 10/5/23.
//

import AudioToolbox
import UIKit
public enum Vibration: CaseIterable {
	case system
	case heavy
	case light
	case medium
	case rigid
	case soft
	public func vibrate() {
		switch self {
		case .system:
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		case .heavy:
			let generator = UIImpactFeedbackGenerator(style: .heavy)
			generator.impactOccurred()
		case .light:
			let generator = UIImpactFeedbackGenerator(style: .light)
			generator.impactOccurred()
		case .medium:
			let generator = UIImpactFeedbackGenerator(style: .medium)
			generator.impactOccurred()
		case .rigid:
			let generator = UIImpactFeedbackGenerator(style: .soft)
			generator.impactOccurred()
		case .soft:
			let generator = UIImpactFeedbackGenerator(style: .soft)
			generator.impactOccurred()
		}
	}
}
