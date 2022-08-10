//
//  Threading.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// would have made this a static function on task but extending it apparently has issues??
public func sleep(seconds: Double) async {
    let duration = UInt64(seconds * 1_000_000_000)
    do {
        try await Task.sleep(nanoseconds: duration)
    } catch {
        debug("Sleep function was interrupted")
    }
}

// TODO: make sure all this is replace with new async-await code.

/// Support locking to make sure multiple threads aren't trying to operate simultaneously.
/// Requires a reference-type object.
public func synchronized(_ lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    defer { // make sure this gets released even if exit the loop prematurely
        objc_sync_exit(lock)
    }
    closure()
}

/// run code on a background thread
//@available(*, deprecated: 1.0, message: "Is this worth saving the code or not?")
public func background(_ closure: @escaping () -> Void) {
    // run this block code on a background thread - todo; remove when moving to swift 3?
    DispatchQueue.global().async {
        // background code here
        closure()
    }
}

/// run code on the main thread
//@available(*, deprecated: 1.0, message: "Is this worth saving the code or not?")
public func main(_ closure: @escaping () -> Void) {
    // DispatchQueue.main.async {} - todo; remove when moving to swift 3?
    DispatchQueue.main.async {
        // finish up on main thread
        closure()
    }
}

// from http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
/**
Utility function to delay execution of code by a certain amount of seconds.

Usage:
```
delay(0.4) {
// do stuff
}
```
*/
/// run the block of code on the main thread after the `delay` (in seconds) have passed.
public func delay(_ delay:Double, closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        // delay below was previously: Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        deadline: DispatchTime.now() + delay, execute: closure)
}
