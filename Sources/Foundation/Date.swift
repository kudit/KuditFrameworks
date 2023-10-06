//
//  Date.swift
//  
//
//  Created by Ben Ku on 8/12/22.
//

import Foundation

extension Date: Testable {} // for testing
public extension Date {
    // TODO: add a conversion from PHP format string to Swift ISO Format string
    // http://www.unicode.org/reports/tr35/tr35-dates.html#Date_Format_Patterns
    init?(from dateString: String, format: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            self = date
        } else {
            return nil
        }
    }
    internal static let testInit: TestClosure = {
        let date = Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")
        //        let date = Date(from: "January 2, 2023 5:12pm", format: "F j, Y g:ia")
		let compareDate = Date(from: "1/2/2023 5:12pm", format: "M/d/y h:mma")
		return (date == compareDate, "\(String(describing: date)) != \(String(describing: compareDate))")
        //        return (date == Date(from: "01/02/2023 17:12", format: "m/d/Y G:i"), String(describing:date))
    }
    
    func formatted(_ format: String) -> String {
        let printFormatter = DateFormatter()
        printFormatter.dateFormat = format
        return printFormatter.string(from: self)
    }
    internal static let testFormatted: TestClosure = {
        let date = Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")
        let formatted = date?.formatted("Y-M-d h:m")
        return (formatted == "2023-1-2 5:12", String(describing:formatted))
    }
    
    var pretty: String {
        self.formatted(date: .abbreviated, time: .shortened)
    }
    internal static let testPretty: TestClosure = {
        let date = Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")
        let pretty = date?.pretty ?? "FAILED"
		return (pretty == "Jan 2, 2023 at 5:12 PM", String(describing:pretty))
    }
    
    static var tests = [
        Test("init with format", testInit),
        Test("formatted", testFormatted),
        Test("pretty", testPretty),
    ]
}

#if canImport(SwiftUI)
import SwiftUI
struct Date_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("\(String(describing: Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")))")
            Text("\(String(describing: Date(from: "1/2/2023 5:12", format: "M/d/y h:mm")))")
            Text("\(String(describing: Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")?.formatted("Y-M-d h:m")))")
            Text("\(String(describing: Date(from: "2023-01-02 17:12:00", format: "yyyy-MM-dd HH:mm:ss")?.pretty))")
        }
    }
}
#endif
