//
//  CodingParameters.swift
//
//
//  Created by Ben Ku on 10/5/23.
//

import Foundation

public struct ParameterEncoding {
    /// Encode an encodable item as a set of keyed parameters designed for a URL.  All values need to be custom string convertable to their value which will be URL encoded.
    public static func encode<T: Encodable>(_ item: T) throws -> String {
        let encoder = DictionaryEncoder()
        guard let encoded: [String: Any] = try encoder.encode(item) as? [String : Any] else {
            throw EncodingError.invalidValue(item, EncodingError.Context(codingPath: [], debugDescription: "Can't encode item to parameter.  Possible non-leaf value."))
        }
        return Self.encodeDictionary(encoded)
    }
    
    // helper function for encoding a dictionary as parameters
    // hopefully nil values are automatically left out of dictonary encoding
    public static func encodeDictionary(_ dictionary: [String: Any]) -> String {
        return dictionary
            .compactMap { (key, value) -> String? in
                if value is [String: Any] {
                    if let dictionary = value as? [String: Any] {
                        return encodeDictionary(dictionary)
                    }
                }
                else {
                    let valueString = "\(value)".urlEncoded
                    return "\(key)=\(valueString)"
                }
                
                return nil
            }
            .joined(separator: "&")
    }
}
