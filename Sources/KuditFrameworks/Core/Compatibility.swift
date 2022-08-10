import Foundation

// for fetchURL() and sleep() functions


// PHP function convenience functions
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

public extension URLSession {
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
    // Sleep extension for sleeping a thread in seconds
    static func sleep(_ seconds: Double) async {
        await sleep(seconds)
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
