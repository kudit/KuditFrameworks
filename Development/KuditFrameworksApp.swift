import SwiftUI
import KuditFrameworks

@main
struct KuditFrameworksApp: App {
    init() {
//        DebugLevel.currentLevel = .WARNING
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
