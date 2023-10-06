public struct KuditFrameworks {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

//TODO: Instead of creating KuditConnect specific button, add KuditConnect features like reporting issues and sending Kudos as options under the Share button?


public extension Bool {
	 static var iOS16_4: Bool {
		 guard #available(iOS 16.4, *) else {
			 return false
		 }
		 return true
	 }
 }
