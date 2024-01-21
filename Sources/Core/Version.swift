import Foundation

/// Version in dot notation
public struct Version: ExpressibleByStringLiteral, RawRepresentable, Hashable, Comparable, Codable, CustomStringConvertible, LosslessStringConvertible, Testable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    public init(stringLiteral: String) {
        self = Version(rawValue: stringLiteral)
    }
    /*public init?(_ description: String) {
        self.init(rawValue: description)
        for item in self.components {
            if item < 0 {
                return nil
            }
        }
    }*/
    public var description: String {
        return rawValue
    }
    
    /// MAJOR version when you make incompatible API changes
    public var major: Int {
        return self.components[safe: 0] ?? 0
    }
    /// MINOR version when you add functionality in a backward compatible manner
    public var minor: Int {
        return self.components[safe: 1] ?? 0
    }
    /// PATCH version when you make backward compatible bug fixes
    public var patch: Int {
        return self.components[safe: 2] ?? 0
    }

    public var components: [Int] {
        self.rawValue.components(separatedBy: ".").map { Int($0) ?? -1 }
    }

    static func makeComparable(left: Version, right: Version) -> ([Int], [Int]) {
        var lc = left.components
        var rc = right.components
        let count = max(lc.count, rc.count)
        lc.pad(to: count, with: 0)
        rc.pad(to: count, with: 0)
        return (lc, rc)
    }
    
    public static func == (left: Version, right: Version) -> Bool {
        let (lc, rc) = makeComparable(left: left, right: right)
        return lc == rc
    }
    public static func < (left: Version, right: Version) -> Bool {
        let (lc, rc) = makeComparable(left: left, right: right)
        for index in 0..<lc.count {
            if lc[index] < rc[index] {
                return true
            }
            if rc[index] < lc[index] {
                return false
            }
            // lc[index] == rc[index]
            // continue down the numbers
        }
        return false // likely entirely ==
    }
    
    internal static let testVersion: TestClosure = {
        let first = Version("2")
        let second = Version("12.1")
        let third: Version = "2.12.1"
        let fourth: Version = "12.1.0"
        var check = first < second && third > first && fourth == second && third < fourth
        return (check, "\(first) < \(second) && \(third) > \(first) && \(fourth) == \(second) && \(third) < \(fourth)")
    }
    public static var tests = [
        Test("Version comparisons", Version.testVersion),
    ]
}

// With ExpressibleByStringLiteral, is this still necessary?
public extension String {
    init(_ version: Version) {
        self = version.rawValue
    }
}

public extension [Version] {
    var asStringArray: [String] {
        self.map { $0.rawValue }
    }
    func joined(separator: String = "") -> String {
        asStringArray.joined(separator: separator)
    }
}

// Don't know why this is necessary.  CustomStringConvertible should have covered this.
import SwiftUI
public extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(_ value: Version) {
        appendInterpolation(value.description)
    }
}

#Preview("Tests") {
    TestsListView(tests: Version.tests)
}
