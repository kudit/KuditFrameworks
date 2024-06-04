import Foundation
@_exported import Device // make available outside this framework by simply importing KuditFrameworks

public struct KuditFrameworks {
    /// The version of the Device Library (must be hard coded because inaccessible from the bundle for included packages)
    public static var version = Version("4.3.5")

    public init() {
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
