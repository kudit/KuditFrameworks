//
//  Dictionary.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/19/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

public extension Dictionary where Value: AnyObject {
    /// return the first encountered key for the given class object.
    func key(for value: AnyObject) -> Key? {
        for (key, val) in self {
            if val === value {
                return key
            }
        }
        return nil
    }
}
public extension Dictionary where Value: Equatable {
    /// return the first encountered key for the given equatable value.
    func key(for value: Value) -> Key? {
        for (key, val) in self {
            if val == value {
                return key
            }
        }
        return nil
    }
}
