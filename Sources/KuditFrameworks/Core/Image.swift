//
//  Image.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 10/2/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias KuImage = UIImage
public extension UIImage {
    /// helper since we can't conditionally check for watchOS below
    // TODO: remove now that watchOS supports UIImage?
    private static func _namedImage(_ name: String) -> UIImage? {
#if os(watchOS)
        return UIImage(named: name, in: Bundle(for: KuditConnect.self), with: nil)
#else
        return UIImage(named: name, in: Bundle(for: KuditConnect.self), compatibleWith: nil)
#endif
    }
    
    /// like UIImage(named:) but also checks KuditFrameworks bundle after checking app resources.
    static func named(_ name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        } else if let image = _namedImage(name) {
            return image
        } else {
            return nil
        }
    }
    var infoString: String {
        return "Image (\(width)×\(height) \"\(fileName)\".\(typeExtension))"
    }
}
#elseif canImport(AppKit)
import AppKit
public typealias KuImage = NSImage
public extension NSImage {
	static func named(_ name: String) -> KuImage? {
        if let image = NSImage(named: name) {
            return image
        } else {
            return nil
        }
    }
    var cgImage: CGImage? {
        return nil
    }
}
#else
public typealias KuImage = NSData // images on other platforms aren't supported and will be handled as data representations
public extension KuImage {
    static func named(_ name: String) -> Image? {
        return nil
    }
    var size: CGSize {
        return CGSize(0,0)
    }
    var cgImage: CGImage? {
        return nil
    }
}
#endif

public extension KuImage {
    var fileName: String {
        get { return self.getAssociatedObject(key: #function) as? String ?? "Untitled" }
        set { self.setAssociatedObject(newValue as AnyObject, forKey: #function) }
    }
    
    var width: Double {
        return Double(self.size.width)
    }
    var height: Double {
        return Double(self.size.height)
    }
    
#if os(iOS) || os(tvOS) || os(watchOS)
    var typeExtension: String {
        if self.asPNG() != nil {
            return "png"
            //} else if self.asJPEG(compressionQuality: 1) != nil {
        } else if self.jpegData(compressionQuality: 1) != nil {
            return "jpg"
        } else {
            return "img"
        }
    }
#else
	var typeExtension: String {
        return "img"
    }
#endif
    
    func asPNG() -> Data? {
#if os(iOS) || os(tvOS) || os(watchOS)
        return self.pngData()
#else
        return nil
#endif
    }
    
    @available(*, deprecated, message: "Use image.jpegData(compressionQuality:) instead")
    func asJPEG(compressionQuality: Float) -> Data? {
#if canImport(UIKit)
        self.jpegData(compressionQuality: CGFloat(compressionQuality))
#else
        return nil
#endif
    }
}

