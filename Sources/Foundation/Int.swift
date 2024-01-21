//
//  Int.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 1/9/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public extension Int {
    /// Generates a uniformly random integer between 0 and `max` - 1.
    /// - Warning: Assumes that `max` can fit in a 32 bit int.
    // TODO: change to Int(randomLessThan:) since it's a constructor?  Instead of Int.random( which makes less sense than a contructor.
    static func random(max: Int) -> Int {
        #if os(Linux)
            return Int(random() % max)
        #else
//            arc4random_uniform() is recommended over constructions like ``arc4random() % upper_bound'' as it avoids "modulo bias" when the upper bound is not a power of two.
            return Int(arc4random_uniform(UInt32(max)))
        #endif
    }
}

// Is the above now built-in to swift?  Can we remove?

// MARK: - Ordinal display
public extension Int {
    var ordinal: String {
        get {
            var suffix = "th"
            switch self % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default: ()
            }
            if 10 < (self % 100) && (self % 100) < 20 {
                suffix = "th"
            }
            return String(self) + suffix
        }
        /*
         0 => th
         1 => st
         2 => nd
         3 => rd
         4 => th
         5 => th
         6 => th
         7 => th
         8 => th
         9 => th
         11 => th
         12 => th
         13 => th
         */
    }
}

// Division & Multiplication of Float/Double by Int
public extension Int {
    // NOTE: Static func operators should be defined in one of the argument type extensions, not the return type
    /// Divide left hand side by the right hand side.  For easily dividing by an `Int` since not suppported by the standard library for some reason.
    static func /(lhs: Double, rhs: Int) -> Double {
        return lhs / rhs.doubleValue
    }
    /// Divide left hand side by the right hand side.  For easily dividing by an `Int` since not suppported by the standard library for some reason.
    static func /(lhs: Float, rhs: Int) -> Float {
        return Float(lhs.doubleValue / rhs.doubleValue)
    }
    /// Divide left hand side by the right hand side.  For easily dividing by an `Int` since not suppported by the standard library for some reason.
    static func /(lhs: Int, rhs: Int) -> Double {
        return lhs.doubleValue / rhs
    }
    /// multiple left hand side by the right hand side.  For easily multiplying by an `Int` since this is not suppported by the standard library for some reason.
    static func *<T: ExpressibleByFloatLiteral & DoubleConvertible>(lhs: T, rhs: Int) -> Double {
        return lhs.doubleValue * rhs.doubleValue
    }
    /// multiple left hand side by the right hand side.  For easily multiplying by an `Int` since this is not suppported by the standard library for some reason.
    static func *<T: ExpressibleByFloatLiteral & DoubleConvertible>(lhs: Int, rhs: T) -> Double {
        return lhs.doubleValue * rhs.doubleValue
    }
}


#if canImport(SwiftUI)
import SwiftUI
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(1..<25, id: \.self) { i in
                Text("\(i) -> \(i.ordinal)")
            }
        }
    }
}
#endif

