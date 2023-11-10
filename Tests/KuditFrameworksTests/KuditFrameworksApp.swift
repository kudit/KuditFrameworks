import SwiftUI

@main
struct KuditFrameworksApp: App {
    init() {
        DebugLevel.currentLevel = .NOTICE
    }
    var body: some Scene {
        WindowGroup {
            KuditFrameworksTestView()
        }
    }
}

#Preview("Test View") {
    KuditFrameworksTestView()
}

