//
//  CodingParameters.swift
//
//
//  Created by Ben Ku on 10/5/23.
//

import Foundation

public class ParameterEncoding {
    public func encode<T: Encodable>(_ item: T) throws -> String {
        let encoder = DictionaryEncoder()
        guard let encoded: [String: Any] = try encoder.encode(item) as? [String : Any] else {
            throw EncodingError.invalidValue(item, EncodingError.Context(codingPath: [], debugDescription: "Can't encode item to parameter.  Possible non-leaf value."))
        }
        return encodeDictionary(encoded)
    }
    
    // hopefully nil values are automatically left out of dictonary encoding
    private func encodeDictionary(_ dictionary: [String: Any]) -> String {
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
