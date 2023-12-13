import Foundation

// for flags in swift packages: https://stackoverflow.com/questions/38813906/swift-how-to-use-preprocessor-flags-like-if-debug-to-implement-api-keys
//swiftSettings: [
//    .define("VAPOR")
//]


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


public enum DebugLevel: Comparable, CustomStringConvertible, CaseIterable {
    /// Only use .OFF for setting the current debug level so nothing is printed.  If you wish to disable a debug message, use .SILENT
    case OFF
    case ERROR
    case WARNING
    case NOTICE
    case DEBUG
    case SILENT
    /// Change this value in production to DebugLevvel.ERROR to minimize logging.
    // set default debugging level to .DEBUG (use manual controls to turn OFF if not debug during app tracking since previews do not have app tracking set up nor does it have compiler flags or app init.
    public static var currentLevel = DebugLevel.DEBUG
    
    public static var defaultLevel = DebugLevel.ERROR
    
    /// Set this to `true` to log failed color parsing notices when returning `nil`
    public static var colorLogging = false
    
    /// setting this to false will make debug( act exactly like print(
    public static var includeContext = true
    public var emoji: String {
        switch self {
        case .OFF:
            return "💤"
        case .ERROR:
            return "🛑"
        case .WARNING:
            return "⚠️"
        case .NOTICE:
            return "ℹ️"
        case .DEBUG:
            return "🪲"
        case .SILENT: // should not typically be used
            return "🤫"
        }
    }
    public var symbol: String {
        switch self {
        case .OFF:
            return "-"
        case .ERROR:
            return "•"
        case .WARNING:
            return "!"
        case .NOTICE:
            return ">"
        case .DEBUG:
            return ":"
        case .SILENT: // should not typically be used
            return "z"
        }
    }
    public var color: any KuColor {
        let type = KuColor.DefaultColorType.self
        switch self {
        case .OFF:
            return type.gray
        case .ERROR:
            return type.red
        case .WARNING:
            return type.yellow
        case .NOTICE:
            return type.blue
        case .DEBUG:
            return type.green
        case .SILENT: // should not typically be used
            return type.black
        }
    }
    public var description: String {
        switch self {
        case .OFF:
            return "OFF"
        case .ERROR:
            return "ERROR"
        case .WARNING:
            return "WARNING"
        case .NOTICE:
            return "NOTICE"
        case .DEBUG:
            return "DEBUG"
        case .SILENT:
            return "SILENT"
        }
    }
    /// use to detect if the current level is at least the level.  So if the current level is .NOTICE, .isAtLeast(.ERROR) = true but .isAtLeast(.DEBUG) = false.  Will typically be used like: if DebugLevel.currentLevel.isAtLeast(.DEBUG) to check for whether debugging output is on.  Simplify using convenience static func DebugLevel.isAtLeast(.DEBUG) 
    public func isAtLeast(_ level: DebugLevel) -> Bool {
        return level <= self  
    }
    /// use to detect if the current level is at least the level.  So if the current level is .NOTICE, .isAtLeast(.ERROR) = true but .isAtLeast(.DEBUG) = false.  Will typically be used like: if DebugLevel.isAtLeast(.DEBUG) to check for whether debugging output is on. 
    public static func isAtLeast(_ level: DebugLevel) -> Bool {
        return Self.currentLevel.isAtLeast(level)
    }
    
    mutating func rotate() {
        let cases = DebugLevel.allCases
        guard var index = cases.firstIndex(of: self) else {
            fatalError("Unknown case!")
        }
        index++
        if index >= cases.count {
            index = 0
        }
        // can't print or access the currentLevel while mutating the same value
//        print("Current debug level: \(DebugLevel.currentLevel.description)")
        //print("Rotating to: \(index): \(cases[index].description)")
        self = cases[index]
//        print("Current debug level: \(DebugLevel.currentLevel.description)")
    }
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
    guard DebugLevel.isAtLeast(level) else {
        return
    }
    let simplerFile = URL(fileURLWithPath: file).lastPathComponent
    let simplerFunction = function.replacingOccurrences(of: "__preview__", with: "_p_")
    let threadInfo = Thread.isMainThread ? "" : "^"
    if DebugLevel.includeContext {
        print("\(simplerFile)(\(line)) : \(simplerFunction)\(threadInfo)\n\(level.emoji) \(message)")
    } else {
        print(message)
    }
}
