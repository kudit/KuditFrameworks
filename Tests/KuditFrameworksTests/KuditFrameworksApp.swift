import SwiftUI
#if canImport(KuditFrameworks)
import KuditFrameworks
#endif

@main
struct KuditFrameworksApp: App {
    init() {
//        DebugLevel.currentLevel = .WARNING
        debug("in App init()", level: DebugLevel.currentLevel)
    }
    var body: some Scene {
        WindowGroup {
			#if os(watchOS) || os(tvOS)
			Text("Kudit Frameworks test")
			#else
            KuditFrameworksTestView()
			#endif
        }
    }
}

#if !os(watchOS) && !os(tvOS)
#Preview("Test View") {
    KuditFrameworksTestView()
}
#endif
