import Foundation

@available(*, deprecated, renamed: "CustomError")
public typealias KuError = CustomError 

// TODO: see if there's a way to add interpolation as a parameter to customize the output format.  Perhaps using a debug output formatter object that can be set?
// Documentation Template:
/**
 Creates a personalized greeting for a recipient.
 
 - Parameter recipient: The person being greeted.
 
 - Throws: `MyError.invalidRecipient`
 if `recipient` is "Derek"
 (he knows what he did).
 
 - Returns: A new string saying hello to `recipient`.
 */



// parameters to add to function that calls debug:
// , file: String = #file, function: String = #function, line: Int = #line, column: Int = #column
// debug call site additions:
// , file: file, function: function, line: line, column: column
// Formerly KuError but this seems more applicable and memorable
public enum CustomError: Error {
    case custom(String)
    public init(_ message: String, level: DebugLevel = DebugLevel.defaultLevel, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        debug(message, level: level, file: file, function: function, line: line, column: column)
        self = .custom(message)
    }
}

public enum DebugLevel: Comparable {
    case OFF
    case ERROR
    case WARNING
    case NOTICE
    case DEBUG
    public static var currentLevel = DebugLevel.DEBUG
    public static var defaultLevel = DebugLevel.ERROR
}
//DebugLevel.currentLevel = .ERROR
/**
 Ku: Debug helper for printing info to screen including file and line info of call site.  Also can provide a log level for use in loggers or for globally turning on/off logging. (Modify DebugLevel.currentLevel to set level to output.  When launching app, probably can set this to DebugLevel.OFF
 
 - Parameter message: The message to report.
 - Parameter level: The logging level to use.
 - Parameter file: For bubbling down the #file name from a call site.
 - Parameter function: For bubbling down the #function name from a call site.
 - Parameter line: For bubbling down the #line number from a call site.
 - Parameter column: For bubbling down the #column number from a call site. (Not used currently but here for completeness).
 */
public func debug(_ message: Any, level: DebugLevel = DebugLevel.defaultLevel, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    guard level <= DebugLevel.currentLevel else {
        return
    }
    let simplerFile = URL(fileURLWithPath: file).lastPathComponent
    let simplerFunction = function.replacingOccurrences(of: "__preview__", with: "_p_")
    let threadInfo = Thread.isMainThread ? "" : "^"
    print("\(simplerFile)(\(line)) : \(simplerFunction)\(threadInfo)\n\(message)")
}
