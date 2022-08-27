import Foundation

// JSONOptional.encode(codableObject, prettyPrinted: true) // encode
// JSONOptional.decode(Codable.Type.self, from: jsonString) // decode

//@available(*, deprecated, message: "Codable methods should be used instead including .asJSON and init(fromJSON:)")
public class JSONOptional {
    public static func encode<T:Encodable>(_ object: T, prettyPrinted: Bool = false) -> String? {
        let encoder = JSONEncoder()
        if (prettyPrinted) {
            encoder.outputFormatting = .prettyPrinted
        }
        do {
            let data = try encoder.encode(object)
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            return nil
        }
    }
    public static func decode<T: Decodable>(_ type: T.Type, from jsonString: String, managedObjectContext: NSManagedObjectContext? = nil) -> T? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        if let context = CodingUserInfoKey.managedObjectContext, let moc = managedObjectContext {
            decoder.userInfo[context] = moc
        }
        let object = try? decoder.decode(type, from: data)
        if let moc = managedObjectContext {
            do {
                try moc.save()
            } catch let error {
                print("Unable to decode managed object: \(error)")
                return nil
            }
        }
        return object
    }
}

import CoreData

// For NSManagedObjects
public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
/* Example for NSManagedObjects:
https://medium.com/@kf99916/codable-nsmanagedobject-and-cllocation-in-swift-4-b32f042cb7d3
class Person: NSManagedObject, Decodable {
    @NSManaged var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    required convenience init(from decoder: Decoder) throws {
        // Create NSEntityDescription with NSManagedObjectContext
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: managedObjectContext) else {
                fatalError("Failed to decode Person!")
        }
        self.init(entity: entity, insertInto: nil)
        
        // Decode
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }
}
*/

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
            return "JSON Encoding error."
        }
    }
}

public extension Decodable {
    init(fromJSON jsonString: String) throws {
        let jsonData = jsonString.data(using: .utf8)!
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}
