import Foundation

/// MARK: ++ operator for compatibility functions
public postfix func ++(x: inout Int) {
    x += 1
}
internal let testPlusPlus: TestClosure = {
    var value = 3
    value++
    let expected = 4
    return (value == expected, "\(value)++ does not equal \(expected)")
}

// MARK: PHP function convenience functions
// for fetchURL() and sleep() functions
public typealias PostData = [String: Any]
public extension PostData {
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
public struct PHP {
    // getting current unix timestamp
    public static func time() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    internal static let testTime: TestClosure = {
        //debug("Interval: \(NSDate().timeIntervalSince1970)")
        //debug("Time(): \(PHP.time())")
        let interval = Int(NSDate().timeIntervalSince1970)
        let time = PHP.time()
        return (interval == time, "\(interval) != \(time)")
    }
    
    public enum NetworkError: Error, CustomStringConvertible {
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

public extension PHP { // Not sure why it compiles when in an extension but not in the main declaration.  Gives async error in the wrong place.
    static func fetchURL(urlString: String, postData: PostData? = nil, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) async throws -> String {
        debug("Fetching URL [\(urlString)]...", level: .NOTICE, file: file, function: function, line: line, column: column)
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
        debug("FETCHING: \(request)", level: .DEBUG, file: file, function: function, line: line, column: column)
        
        var data: Data
        // create dataTask using the session object to send data to the server
        if #available(iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
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
    internal static let TEST_DATA: PostData = ["id": 13, "name": "Jack & \"Jill\"", "foo": false, "bar": "0.0"]
    internal static let testPostDataQueryEncoding: TestClosure = {
        //debug(testData.queryString ?? "Unable to generate query string")
        let query = TEST_DATA.queryString ?? "Unable to generate query string"
        let expected = "name=Jack%20%26%20%22Jill%22"
        return (query.contains(expected), "\(query) does not contain \(expected)")
    }
    internal static let testFetchGwinnettCheck: TestClosure = {
        let results = try await fetchURL(urlString: "https://www.GwinnettCounty.com")
        return (results.contains("Gwinnett"), results)
    }
    internal static let testFetchGETCheck: TestClosure = {
        let query = TEST_DATA.queryString ?? "ERROR"
        let results = try await fetchURL(urlString: "https://plickle.com/pd.php?\(query)")
        return (results.contains("[name] => Jack & \"Jill\""), results)
    }
    internal static let testFetchPOSTCheck: TestClosure = {
        let results = try await fetchURL(urlString: "https://plickle.com/pd.php", postData:TEST_DATA)
        return (results.contains("'name' => 'Jack & \\\"Jill\\\"',"), results)
    }
}

extension PHP: Testable {
    public static var tests: [Test] = [
        Test("plusplus", testPlusPlus),
        Test("time", testTime),
        Test("POST data query encoding", testPostDataQueryEncoding),
        Test("fetchURL Gwinnett check", testFetchGwinnettCheck),
        Test("fetchURL GET check", testFetchGETCheck),
        Test("fetchURL POST check", testFetchPOSTCheck),
        Test("sleep 3", testSleep1),
        Test("sleep 2", testSleep2),
    ]
}

#if canImport(SwiftUI)
import SwiftUI
struct Compatibility_Previews: PreviewProvider {
    static var previews: some View {
        TestsListView(tests: PHP.tests)
    }
}
#endif
