//
//  DictionaryCoding.swift
//  Shout It
//
//  Created by Ben Ku on 9/28/23.
//
import Foundation

public class DictionaryEncoder {
    public init() {}
    /// Encodes given Encodable value into an array or dictionary
    public func encode<T>(_ value: T) throws -> Any where T: Encodable {
        let jsonData = try JSONEncoder().encode(value)
        return try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
    }
}

public class DictionaryDecoder {
    public init() {}
    /// Decodes given Decodable type from given array or dictionary (converts to JSON then uses JSON decoder)
    public func decode<T>(_ type: T.Type, from jsonObject: Any) throws -> T where T: Decodable {
        let jsonString = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return try JSONDecoder().decode(type, from: jsonString)
    }
}

/**
 
 https://stackoverflow.com/questions/45209743/how-can-i-use-swift-s-codable-to-encode-into-a-dictionary
 
 
 struct Computer: Codable {
     var owner: String?
     var cpuCores: Int
     var ram: Double
 }

 let computer = Computer(owner: "5keeve", cpuCores: 8, ram: 4)
 let dictionary = try! DictionaryEncoder().encode(computer)
 let decodedComputer = try! DictionaryDecoder().decode(Computer.self, from: dictionary)

 */
