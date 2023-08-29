//
//  String.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 1/8/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// for NSDocumentTypeDocumentAttribute
//#if os(OSX)
//    import AppKit
//#elseif os(iOS) || os(tvOS)
//    import UIKit
//#endif

public extension URL {
    var fileBasename: String {
        return self.deletingPathExtension().lastPathComponent
    }
}

extension URL: Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        return lhs.path < rhs.path
    }
}

public extension URL {
    /// download data asynchronously and return the data or nil if there is a failure
    func download() async throws -> Data {
        let (fileURL, response) = try await URLSession.shared.download(from: self)
            
        debug("URL Download response: \(response)", level: .DEBUG)
            
        // load data from local file URL
        let data = try Data(contentsOf: fileURL)
            
        return data
    }
}
