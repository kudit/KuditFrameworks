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

struct KuditFrameworksApp_Previews: PreviewProvider {
    static var previews: some View {
        KuditFrameworksTestView()
    }
}
