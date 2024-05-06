import SwiftUI
#if canImport(KuditFrameworks) // since this is needed in XCode but is unavailable in Playgrounds.
import KuditFrameworks
#endif

@main
struct KuditFrameworksApp: App {
    init() {
        // Remove before launch.  This allows a warning to be generated during debugging to help remind the developer to remove before releasing.  Set to false during debugging and true for launch.
        if true { // this will generate a warning if left as false
            DebugLevel.currentLevel = .NOTICE
        }
        Application.track()
        debug("in App init()", level: DebugLevel.currentLevel)
    }
    var body: some Scene {
        WindowGroup {
            KuditFrameworksTestView()
        }
    }
}

#Preview("for Xcode") {
    KuditFrameworksTestView()
}
