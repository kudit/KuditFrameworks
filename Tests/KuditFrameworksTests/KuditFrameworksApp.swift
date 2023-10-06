import SwiftUI

@available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, *)
@main
struct KuditFrameworksApp: App {
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
