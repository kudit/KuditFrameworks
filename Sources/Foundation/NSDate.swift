//
//  NSDate.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 2/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation
#if canImport(Darwin)
import Darwin
#elseif os(Linux)
import Glibc
#endif

// TODO: CONVERT all this to swift versions
public extension Date {
    @nonobjc static let MySQLTimestampFormat = "yyyy-MM-dd HH:mm:ss"
    
    /// create a date from a `dateString` in the specified `format`
    /// TODO: see NSDateFormatter dateFormat string for information
    init(dateString:String, format formatString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = formatString
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
    
    /// create a date given the number of seconds since midnight.
    init(timeIntervalSinceMidnight: TimeInterval) {
        self.init(timeInterval:timeIntervalSinceMidnight, since:Date().midnight)
    }
    
    /// Return the date formmated using the `formatString`.  See NSDateFormatter for format information.
    func string(withFormat formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        return formatter.string(from: self)
    }

    /// Use date formatter style to create localized string version of the date.
    func string(withStyle dateFormatterStyle:DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateFormatterStyle
        return formatter.string(from: self)
    }
    
    /// return the integer value of the year component.
    var year:Int {
        return Calendar.current.component(.year, from: self)
    }
    
    // NEXT: add month and day values?
    
    // MARK: - Tests
    func isSameDate(as otherDate: Date) -> Bool {
        // changed NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit to new values since deprecated in iOS 8 (I think these should be available starting with iOS 7, so shouldn't hurt compatibility)
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.era, .year, .month, .day], from: otherDate)
        let compareDate = calendar.date(from: components)
        components = (calendar as NSCalendar).components([.era, .year, .month, .day], from: self)
        let normalizedDate = calendar.date(from: components)
        return (compareDate == normalizedDate!)
    }
    var hasPassed: Bool {
        return self.timeIntervalSinceNow < 0
    }
    var isToday: Bool {
        return self.isSameDate(as: Date())
    }
    var isYesterday: Bool {
        return self.isSameDate(as: Date(timeIntervalSinceNow: -60*60*24))
    }
    // age related
    // TODO: rename to isOlderThan(days:
    func isOlderThanDays(_ days: Double) -> Bool {
        return self.isOlderThanHours(days * 24)
    }
    // TODO: rename to isOlderThan(hours:
    func isOlderThanHours(_ hours: Double) -> Bool {
        return self.isOlderThanSeconds(hours * 60 * 60)
    }
    // TODO: rename to isOlderThan(seconds:
    func isOlderThanSeconds(_ seconds: Double) -> Bool {
        let delta = -self.timeIntervalSinceNow
        return delta > seconds
    }
    // TODO: add hasBeen(days:, etc?  Or does hasPassed take care of this?  Is there a default method that handles the above cases too?
    // midnight
    var midnight: Date {
        var components = (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self)
        // Now we'll reset the hours and minutes of the date components so that it's now pointing at midnight (start) for the day
        components.hour = 0
        components.minute = 0
        components.second = 0
        // Next, we'll turn it back in to a date:
        return Calendar.current.date(from: components)!
    }
    var timeIntervalSinceMidnight: TimeInterval {
        return self.timeIntervalSince(midnight)
    }
}
