import SwiftUI
import KuditFrameworks

@main
struct KuditFrameworksApp: App {
    init() {
        // Remove before launch.  This allows a warning to be generated during debugging to help remind the developer to remove before releasing.  Set to false during debugging and true for launch.
        if true {
            DebugLevel.currentLevel = .NOTICE
        }
        debug("in App init()", level: DebugLevel.currentLevel)
    }
    var body: some Scene {
        WindowGroup {
            #if os(watchOS) || os(tvOS) || os(visionOS)
            Text("Kudit Frameworks test")
            #else
            KuditFrameworksTestView()
            #endif
        }
    }
}
