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
