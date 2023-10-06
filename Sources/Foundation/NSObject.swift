//
//  NSObject.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// TODO: See if this is used anywhere
extension NSObject {
    // example deprecation:
    @available(*, deprecated, message: "Why are you even using this?")
    public func foobar() {
        print("This does nothing")
    }
    
    // must have class object to have address of obejct below?
    fileprivate class KuditAssociatedObjectValue {}
    fileprivate class KuditAssociatedObjectKeys {
        static var keys = [String: KuditAssociatedObjectValue]()
    }
    // http://stackoverflow.com/questions/24058906/printing-a-variable-memory-address-in-swift
    fileprivate func associatedAddressForKey(_ key: String) -> UnsafeMutableRawPointer {
        // map key to address
        if KuditAssociatedObjectKeys.keys[key] == nil {
            KuditAssociatedObjectKeys.keys[key] = KuditAssociatedObjectValue()
        }
        let pointer = KuditAssociatedObjectKeys.keys[key]!
        return Unmanaged.passUnretained(pointer).toOpaque()
    }
    // http://rosettacode.org/wiki/Add_a_variable_to_a_class_instance_at_runtime#Objective-C
    // http://nshipster.com/swift-objc-runtime/
    // can use selectors since the string address won't necessarily be the same if not a static string
    /// add an associated object/value to this object
    public func setAssociatedObject(_ object: AnyObject!, forKey key: String) {
        objc_setAssociatedObject(self, associatedAddressForKey(key), object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    public func getAssociatedObject(key: String) -> AnyObject! {
        return objc_getAssociatedObject(self, associatedAddressForKey(key)) as AnyObject
    }

    
    
    
    // MARK: - Example Usage
    /// Example usage adds kuditExampleProperty to all NSObjects
    public var kuditExampleProperty: String? {
        get { return self.getAssociatedObject(key: #function) as? String }
        set { self.setAssociatedObject(newValue as AnyObject, forKey: #function) }
    }
    public var kuditExampleBool: Bool {
        get {
            if let value = self.getAssociatedObject(key: #function) {
                return value as! Bool
            }
            return false
        }
        set { self.setAssociatedObject(newValue as AnyObject, forKey: #function) }
    }
}
