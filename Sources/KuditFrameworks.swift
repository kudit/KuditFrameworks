

public struct KuditFrameworks {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

public extension Bool {
     static var iOS16_4: Bool {
         guard #available(iOS 16.4, *) else {
             return false
         }
         return true
     }
 }


/** Possible additions to Device Kit
/// Gets the identifier from the system, such as "iPhone7,1".
public static var identifier: String = {
  var systemInfo = utsname()
  uname(&systemInfo)
  let mirror = Mirror(reflecting: systemInfo.machine)

  let identifier = mirror.children.reduce("") { identifier, element in
    guard let value = element.value as? Int8, value != 0 else { return identifier }
    return identifier + String(UnicodeScalar(UInt8(value)))
  }
  return identifier
  /* Possible code for macOS using IOKit:
   
   let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                             IOServiceMatching("IOPlatformExpertDevice"))
   var modelIdentifier: String?
   if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
       modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
   }

   IOObjectRelease(service)
   return modelIdentifier
*/
}()
 */
