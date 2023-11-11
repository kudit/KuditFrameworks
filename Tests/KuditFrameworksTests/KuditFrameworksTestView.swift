import SwiftUI
#if canImport(KuditFrameworks) // since this is needed in XCode but is unavailable in Playgrounds
import KuditFrameworks
#endif
#if !os(watchOS) && !os(tvOS)

struct TimeClockView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = -1
    var body: some View {
        Text("Unix time: \(time)").onReceive(timer, perform: { _ in
            //debug("updating \(time)")
            time = PHP.time()
        })
    }
}

public struct KuditFrameworksTestView: View {
    public init() {
        //debug("Test View Init")
        Application.track()
    }
    
    @State var testIsPresented = false
    
    public var body: some View {
        NavigationView {
            VStack {
                KuditLogo()
                    .frame(size: 44)
                Text("Hello, Kudit world!")
//                let encoded = KuditConnect.shared.faqs.asJSON()
  //              Text(encoded)
                //let decode = try! JSONDecoder().decode([KuditFAQ].self, from: encoded.asData())
//                Text("\(.decod("12") < Version("2") ? "true" : "false")")
                TimeClockView()
                Text(KuditConnect.shared.appInformation)
                    .padding()
//                ColorPrettyTests()
            }
            .navigationTitle("Kudit Frameworks")
            .toolbar {
                KuditConnectMenu()
//                Menu("Test") {
//                    Button("Show Sheet") {
//                        testIsPresented = true
//                    }
//                }
//                .sheet(isPresented: $testIsPresented) {
//                    Button("Dismiss") {
//                        testIsPresented = false
//                    }
//                    ColorPrettyTests()
//                    TestsListView(tests: Color.tests + CharacterSet.tests + String.tests + PHP.tests)
//                }
            }
        }
#if !os(macOS)
		.navigationViewStyle(.stack)
#endif
    }
}
#endif
