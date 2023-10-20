

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
