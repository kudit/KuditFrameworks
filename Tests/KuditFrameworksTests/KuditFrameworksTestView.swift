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
        NavigationView {
            VStack {
                KuditLogo()
                    .frame(size: 44)
                Text("Hello, Kudit world!")
                Text("Unix time: \(time)").onReceive(timer, perform: { _ in
                    //debug("updating \(time)")
                    time = PHP.time()
                })
                Text(KuditConnect.shared.appInformation)
            }
            .navigationTitle("Kudit Frameworks")
            .toolbar {
                KuditConnectMenu()
            }
        }
    }
}
