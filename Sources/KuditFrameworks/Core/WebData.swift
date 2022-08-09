//
//  WebData.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// Functions to help converting from NSData to images or strings (like JSON)

//extension NSData {
//    static func loadFromURL(urlString: String, callback: (NSData?) -> Void) {
//        // run this block code on a background thread
//        background {
//            var data: NSData?
//            defer { // run callback regardless of failure
//                main {
//                    // finish up on main thread
//                    callback(data)
//                }
//            }
//            // background code here
//            guard let url = NSURL(string: urlString) else {
//                print("KWD: Invalid URL String: \(urlString)")
//                return
//            }
//            data = NSData(contentsOfURL: url)
//        }
//    }
//}

// TODO: add checks for GZip data
// TODO: add CSV file and import as keyed objects?  Import into Core Data directly?

// See: https://github.com/Haneke/HanekeSwift/blob/master/Haneke/Data.swift
public protocol DataConvertible {
    associatedtype Result
    static func convertFromData(_ data:Data) -> Result?
    func asData() -> Data! // TODO: what does the ! do here?  Why?
}

extension String : DataConvertible {
    public typealias Result = String
    
    public static func convertFromData(_ data: Data) -> Result? {
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        return string as? Result
    }
    
    public func asData() -> Data! {
        return self.data(using: String.Encoding.utf8)
    }
}

extension Data : DataConvertible {
    public typealias Result = Data
    
    public static func convertFromData(_ data: Data) -> Result? {
        return data
    }
    
    public func asData() -> Data! {
        return self
    }
}

// https://github.com/Haneke/HanekeSwift/blob/master/Haneke/Data.swift
public enum JSON : DataConvertible {
    public typealias Result = JSON

    case Dictionary([String:Any])
    case Array([Any])
    
    public static func convertFromData(_ data: Data) -> Result? {
        do {
            let object : Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            switch (object) {
            case let dictionary as [String:Any]:
                return JSON.Dictionary(dictionary)
            case let array as [Any]:
                return JSON.Array(array)
            default:
                return nil
            }
        } catch {
            print("Invalid JSON data \(error)")
            return nil
        }
    }
    
    /// Create a JSON enum from NSData
    init?(data: Data) {
        guard let results = JSON.convertFromData(data) else {
            return nil
        }
        self = results
    }

    /// Create a JSON enum from NSURL
    init?(url: URL) {
        guard let jsonData = try? Data(contentsOf: url) else {
            return nil
        }
        self.init(data: jsonData)
    }

    /// Create a JSON enum from a URLString
    init?(urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.init(url: url)
    }

    public func asData() -> Data! {
        switch (self) {
        case .Dictionary(let dictionary):
            return try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions())
        case .Array(let array):
            return try? JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions())
        }
    }
    
    public var array : [Any]! {
        switch (self) {
        case .Dictionary(_):
            return nil
        case .Array(let array):
            return array
        }
    }
    
    public var dictionary : [String:Any]! {
        switch (self) {
        case .Dictionary(let dictionary):
            return dictionary
        case .Array(_):
            return nil
        }
    }
}

#if canImport(UIKit)
import UIKit
extension UIImage: DataConvertible {
    public typealias Result = UIImage
    var saveLowRes: Bool {
        get {
            if let value = self.getAssociatedObject(key: #function) {
                return (value as! NSNumber).boolValue
            }
            return false
        }
        set { self.setAssociatedObject(NSNumber(value: newValue), forKey: #function) }
    }
    public class func convertFromData(_ data: Data) -> Result? {
        return UIImage(data:data)
    }
    public func asData() -> Data! {
        if self.saveLowRes {
            return self.jpegData(compressionQuality: 0.9)
        } else {
            return self.pngData() // store as PNG to keep lossless and transparency if it exists
        }
    }
}
#endif
