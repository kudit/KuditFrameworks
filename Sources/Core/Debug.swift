import Foundation

public enum KuError: Error {
	case custom(String)
	public init(_ message: String, level: DebugLevel = .DEBUG) {
		debug(message, level: level)
		self = .custom(message)
	}
}

public enum DebugLevel: Comparable {
	case ERROR
	case WARNING
	case NOTICE
	case DEBUG
	static let currentLevel = DebugLevel.DEBUG
}
public func debug(_ message: Any, level: DebugLevel = .DEBUG, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
	guard level <= DebugLevel.currentLevel else {
		return
	}
	let simplerFile = URL(fileURLWithPath: file).lastPathComponent
	let simplerFunction = function.replacingOccurrences(of: "__preview__", with: "_p_")
	let threadInfo = Thread.isMainThread ? "" : "^"
	print("\(simplerFile)(\(line)) : \(simplerFunction)\(threadInfo)\n\(message)")
}
