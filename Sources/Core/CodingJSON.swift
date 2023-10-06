import Foundation

// MARK: - JSON management (simplified)

public extension Encodable {
    func asJSON(outputFormatting: JSONEncoder.OutputFormatting? = nil) -> String {
        let encoder = JSONEncoder()
        if (outputFormatting != nil) {
            encoder.outputFormatting = outputFormatting!
        }
        do {
            let data = try encoder.encode(self)
            let json = String(data: data, encoding: .utf8)!
            return json
        } catch {
			// Since conforms to Encodable, should not have any error encoding using JSONEncoder.
			let errorMessage = "JSON Encoding error: \(error)"
			debug(errorMessage, level: .ERROR)
            return errorMessage
        }
    }
}

public extension Decodable {
    init(fromJSON jsonString: String) throws {
        let jsonData = jsonString.data(using: .utf8)!
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}
