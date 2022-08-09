import Foundation


public struct KuditFrameworks {
	public private(set) var text = "Hello, World!"

	public init() {
	}
}

// TODO: Move this to Core/Debug and Core/Tests


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

// Test Handlers
@available(macOS 10.15, *)
@available(iOS 13.0, *)
public class Test: CustomStringConvertible, ObservableObject {
	public enum TestProgress: CustomStringConvertible {
		case notStarted
		case running
		case pass
		case fail
		public var description: String {
			switch self {
			case .notStarted:
				return "❇️"
			case .running:
				return "🔄"
			case .pass:
				return "✅"
			case .fail:
				return "⛔"
			}
		}
	}
	typealias TestClosure = () async throws -> (Bool, String)
	var title: String
	var task: TestClosure
	@Published var progress: TestProgress = .notStarted
	@Published var errorMessage: String? = nil
	
	init(_ title: String, _ task: @escaping TestClosure ) {
		self.title = title
		self.task = task
	}
	
	func run() {
		self.progress = .running
		// make sure to run the "work" in a separate thread since we don't want any of this running on the main thread and potentially bogging things down
		Task {
			do {
				//await PHP.sleep(2)
				let (result, debugString) = try await task()
				progress = result ? .pass : .fail
				if !result {
					print("•\(title) Failed:\n\(debugString)")
				}
				//debug("Complete \(self)")
			} catch {
				errorMessage = "Error: \(error)"
				progress = .fail
				print("•\(title) Errored:\n\(self)")
			}
		}
	}
	
	public var description: String {
		let errorString = (errorMessage != nil ? "\n\t\(errorMessage!)" : "")
		return "\(progress): \(title)\(errorString))"
	}
}
@available(macOS 10.15, *)
@available(iOS 13.0.0, *)
public extension Test {
	static func dummyAsyncThrows() async throws {
	}
}

// PHP function convenience functions
public typealias PostData = [String: Any]
extension PostData {
	var queryString: String? {
		//return "fooish=barish&baz=buzz"
		var items = [URLQueryItem]()
		for (key, value) in self {
			items.append(URLQueryItem(name: key, value: "\(value)"))
		}
		var urlComponents = URLComponents()
		urlComponents.queryItems = items
		return urlComponents.url?.query
	}
	var queryEncoded: Data? {
		return queryString?.data(using: .utf8)
	}
}
struct PHP {
	static var initTests = PHP.tests
	// getting current unix timestamp
	static func time() -> Int {
		return Int(NSDate().timeIntervalSince1970)
	}
	
	enum NetworkError: Error, CustomStringConvertible {
		// Throw when unable to parse a URL
		case urlParsing(urlString: String)
		
		case postDataEncoding(_ data: PostData)
		
		// Invalid HTTP response (with response code)
		case invalidResponse(code: Int? = nil)
		
		case nilResponse
		
		public var description: String {
			switch self {
			case .urlParsing(let urlString):
				return "URL could not be created from \(urlString)"
			case .postDataEncoding(let data):
				return "Post Data could not be encoded from \(data)"
			case .invalidResponse(let code):
				return "Invalid Response (\(code != nil ? "\(code!)" : "No code")) received from the server"
			case .nilResponse:
				return "nil Data received from the server"
			}
		}
	}
	
	static var tests: [Test] {
		let testData: PostData = ["id": 13, "name": "Jack & \"Jill\"", "foo": false, "bar": "0.0"]
		return [
			Test("Checking time() function") {
				//debug("Interval: \(NSDate().timeIntervalSince1970)")
				//debug("Time(): \(PHP.time())")
				let interval = Int(NSDate().timeIntervalSince1970)
				let time = PHP.time()
				return (interval == time, "\(interval) != \(time)")
			},
			Test("Checking sleep() function") {
				let start = PHP.time()
				await PHP.sleep(2)
				let end = PHP.time()
				let delta = end - start // could be 2 or 3 if on an edge
				return (delta <= 3, "\(start) + 2 != \(end)")
			},
			Test("Post Data query encoding") {
				let testData = testData as PostData
				//debug(testData.queryString ?? "Unable to generate query string")
				let query = testData.queryString ?? "Unable to generate query string"
				let expected = "name=Jack%20%26%20%22Jill%22"
				return (query.contains(expected), "\(query) does not contain \(expected)")
			},
			Test("fetchURL Gwinnett check") {
				let results = try await fetchURL(urlString: "https://www.GwinnettCounty.com")
				return (results.contains("Gwinnett"), results)
			},
			Test("fetchURL GET check") {
				let query = testData.queryString ?? "ERROR"
				let results = try await fetchURL(urlString: "https://plickle.com/pd.php?\(query)")
				return (results.contains("[name] => Jack & \"Jill\""), results)
			},
			Test("fetchURL POST check") {
				let results = try await fetchURL(urlString: "https://plickle.com/pd.php", postData:testData)
				return (results.contains("'name' => 'Jack & \\\"Jill\\\"',"), results)
			}
		]
	}
}

extension URLSession {
	func legacyData(for request: URLRequest) async throws -> (Data, URLResponse) {
		try await withCheckedThrowingContinuation { continuation in
			guard let url = request.url else {
				return continuation.resume(throwing: URLError(.badURL))
			}
			let task = self.dataTask(with: url) { data, response, error in
				guard let data = data, let response = response else {
					let error = error ?? URLError(.badServerResponse)
					return continuation.resume(throwing: error)
				}
				
				continuation.resume(returning: (data, response))
			}
			
			task.resume()
		}
	}
}

extension PHP { // Not sure why it compiles when in an extension but not in the main declaration.  Gives async error in the wrong place.
	// Sleep extension for sleeping a thread in seconds
	static func sleep(_ seconds: Double) async {
		let duration = UInt64(seconds * 1_000_000_000)
		do {
			try await Task.sleep(nanoseconds: duration)
		} catch {
			debug("PHP Sleep function was interrupted")
		}
	}
	
	static func fetchURL(urlString: String, postData: PostData? = nil) async throws -> String {
		debug("Fetching URL [\(urlString)]...", level: .NOTICE)
		// create the url with URL
		guard let url = URL(string: urlString) else {
			throw NetworkError.urlParsing(urlString: urlString)
		}
		
		// now create the URLRequest object using the url object
		var request = URLRequest(url: url)
		if let parameters = postData {
			request.httpMethod = "POST" //set http method as POST
			
			// declare the parameter as a dictionary that contains string as key and value combination. considering inputs are valid
			
			//let parameters: [String: Any] = ["id": 13, "name": "jack"]
			guard let data = postData?.queryEncoded else {
				throw NetworkError.postDataEncoding(parameters)
			}
			request.httpBody = data
		} else {
			request.httpMethod = "GET" //set http method as GET
		}
		debug("FETCHING: \(request)")
		
		var data: Data
		// create dataTask using the session object to send data to the server
		if #available(iOS 15.0, *) {
			(data, _) = try await URLSession.shared.data(for: request)
		} else {
			// Fallback on earlier versions
			(data, _) = try await URLSession.shared.legacyData(for: request)
		}
		
		//debug("DEBUG RESPONSE DATA: \(data)")
		
		if let responseString = String(data: data, encoding: .utf8) {
			//debug("DEBUG RESPONSE STRING: \(responseString)")
			return responseString
		} else {
			throw NetworkError.invalidResponse()
		}
		/*DEBUG:if PHP.time() > 1 {
		 return "Post Data: \(postData != nil ? "\(postData!)" : "none")"
		 } else {
		 throw NetworkError.urlParsing(urlString: urlString)
		 }*/
	}
}

