//
//  DictionaryCoding.swift
//  Shout It
//
//  Created by Ben Ku on 9/28/23.
//
import Foundation

class DictionaryEncoder {
	/// Encodes given Encodable value into an array or dictionary
	func encode<T>(_ value: T) throws -> Any where T: Encodable {
		let jsonData = try JSONEncoder().encode(value)
		return try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
	}
}

class DictionaryDecoder {
	/// Decodes given Decodable type from given array or dictionary
	func decode<T>(_ type: T.Type, from jsonObject: Any) throws -> T where T: Decodable {
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
