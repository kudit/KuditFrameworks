import Foundation

public protocol DoubleConvertible {
    var doubleValue: Double { get }
}
extension Int: DoubleConvertible {
    public var doubleValue: Double {
        return Double(self)
    }
}
extension Float: DoubleConvertible {
    public var doubleValue: Double {
        return Double(self)
    }
}
extension Double: DoubleConvertible {
    public var doubleValue: Double {
        return Double(self)
    }
}

extension Double: Testable {} // for testing
extension Double {
    // TODO: Create Macros to create test code like @Test { code to generate result } { expected result } output should indicate line where the test occurred, description of error, framework that it's part of, etc.  Should also automatically add to a tests static variable that is also automatically registered with gloabl tests.  #Test { should work like #Preview { but generate UI for tests included in this file automatically
    internal static let testAverageing: TestClosure = {
        let intAverage = [1,2,3,4,5,2].average()
        let floatAverage = [1.2,2.3,3.4,4.5,5.6,2.7,7.8].average()
        return (intAverage == (17/6) && floatAverage == (27.5/7), "\(intAverage) != 17/6 or \(floatAverage) != 27.5/7")
    }
    
    internal static let testMultiplication: TestClosure = {
        let multiply = 20.0 * Int(5)
        return (multiply == 100, "\(multiply) != 100")
    }
    
    public static var tests = [
        Test("Averaging", testAverageing),
        Test("Multiplication", testMultiplication),
    ]
}

#if canImport(SwiftUI)
import SwiftUI
#Preview("Double Tests") {
    TestsListView(tests: Double.tests)
}
#endif

