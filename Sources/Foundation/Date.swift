//
//  Date.swift
//  
//
//  Created by Ben Ku on 8/12/22.
//

import Foundation

public extension Date {
    init?(from dateString: String, format: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            self = date
        } else {
            return nil
        }
    }
    
    func formatted(_ format: String) -> String {
        let printFormatter = DateFormatter()
        printFormatter.dateFormat = format
        return printFormatter.string(from: self)
    }
    
    @available(iOS 15.0, *)
    var pretty: String {
        self.formatted(date: .abbreviated, time: .shortened)
    }
    
}
