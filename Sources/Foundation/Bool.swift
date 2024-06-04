//
//  File.swift
//  
//
//  Created by Ben Ku on 6/3/24.
//

import Foundation

public enum OS {
    case iOS
    case macOS
    case macCatalyst
    case tvOS
    case watchOS
    case visionOS
    case Linux
}

public extension Bool {
    /// Determine if we're running on a particular os.  Uses #if os(name) checks to test.
    static func isOS(_ os: OS) -> Bool {
        switch os {
        case .iOS:
#if os(iOS)
            return true
#else
            return false
#endif
        case .macOS:
#if os(macOS)
            return true
#else
            return false
#endif
        case .macCatalyst:
#if targetEnvironment(macCatalyst)
            return true
#else
            return false
#endif
        case .tvOS:
#if os(tvOS)
            return true
#else
            return false
#endif
        case .watchOS:
#if os(watchOS)
            return true
#else
            return false
#endif
        case .visionOS:
#if os(visionOS)
            return true
#else
            return false
#endif
        case .Linux:
#if os(Linux)
            return true
#else
            return false
#endif
        }
    }
}

/*
public extension Bool {
     static var iOS16_4: Bool {
         guard #available(iOS 16.4, *) else {
             return false
         }
         return true
     }
 }
 */

