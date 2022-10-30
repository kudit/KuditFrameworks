import SwiftUI
#if canImport(KuditFrameworks) // since this is needed in XCode but is unavailable in Playgrounds
import KuditFrameworks
#endif

public struct KuditFrameworksTestView: View {
    
    public init() {
        //debug("Test View Init")
        //DebugLevel.currentLevel = .ERROR
        //debug("Bar")
        Application.track()
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var time = -1
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, Kudit world!")
            Text("Unix time: \(time)").onReceive(timer, perform: { _ in
                //debug("updating \(time)")
                time = PHP.time()
            })
            Text("Application Description: \(Application.main.description)")
            Text("Version: v\(Bundle.main.version)")
            Text("Kudit Frameworks: v\(Bundle.kuditFrameworks?.version ?? "!")")
        }
    }
}
