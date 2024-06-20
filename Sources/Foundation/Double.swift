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

// Division & Multiplication of mixed Float/Double
public extension Double {
    /// Divide left hand side by the right hand side.
    /// Note: May cause float rounding errors (2.3 / 5 -> 0.45999999999999996 not 0.46)
    static func /(lhs: Double, rhs: Float) -> Double {
        return lhs / rhs.doubleValue
    }
    /// Divide left hand side by the right hand side.
    static func /(lhs: Float, rhs: Double) -> Double {
        return lhs.doubleValue / rhs
    }

    /// Add left hand side with the right hand side.
    static func +(lhs: Double, rhs: Float) -> Double {
        return lhs + rhs.doubleValue
    }
    /// Add left hand side with the right hand side.
    static func +(lhs: Float, rhs: Double) -> Double {
        return lhs.doubleValue + rhs
    }
    
//    /// multiply left hand side by the right hand side.
//    static func *(lhs: Float, rhs: Double) -> Double {
//        return lhs.doubleValue * rhs
//    }
//    /// multiply left hand side by the right hand side.  For easily multiplying by an `Int` since this is not suppported by the standard library for some reason.
//    static func *(lhs: Double, rhs: Float) -> Double {
//        return lhs * rhs.doubleValue
//    }
}

extension Double: Testable {} // for testing
extension Double {
    // TODO: Create Macros to create test code like @Test { code to generate result } { expected result } output should indicate line where the test occurred, description of error, framework that it's part of, etc.  Should also automatically add to a tests static variable that is also automatically registered with gloabl tests.  #Test { should work like #Preview { but generate UI for tests included in this file automatically
    internal static let testOperations: TestClosure = {
        let floatValue: Float = 5
        let doubleValue: Double = 2.3
        let multiplicationA = floatValue.doubleValue * doubleValue
        let multiplicationB = doubleValue * floatValue.doubleValue
        let divisionMixedA = doubleValue / floatValue
        let divisionMixedB = floatValue / doubleValue
        let additionMixedA = doubleValue + floatValue
        let additionMixedB = floatValue + doubleValue
        return (
            multiplicationA == 11.5
            && multiplicationB == 11.5
            && divisionMixedA == 0.46
            && Int(divisionMixedB * Float(1E8).doubleValue) == 217391305
            && additionMixedA == 7.3
            && additionMixedB == 7.3
            , "\(multiplicationA),\(multiplicationB),\(divisionMixedA),\(divisionMixedB),\(additionMixedA),\(additionMixedB) testOperations failed")
    }

    internal static let testAverageing: TestClosure = {
        let intAverage = [1,2,3,4,5,2].average()
        let floatAverage = [1.2,2.3,3.4,4.5,5.6,2.7,7.8].average()
        return (intAverage == (17/6) && floatAverage == (27.5/7), "\(intAverage) != 17/6 or \(floatAverage) != 27.5/7")
    }
    
    internal static let testMultiplication: TestClosure = {
        let multiply = 20.0 * Int(5)
        return (multiply == 100, "\(multiply) != 100")
    }
    
    @MainActor
    public static var tests = [
        Test("Operations with Floats & Doubles", testOperations),
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

