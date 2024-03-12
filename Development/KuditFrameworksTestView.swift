import SwiftUI
import KuditFrameworks
#if !os(watchOS) && !os(tvOS)

struct TimeClockView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = -1
    var body: some View {
        VStack {
            Text("Unix time: \(time)")
            Button {
                DebugLevel.currentLevel++
            } label: {
                HStack {
                    Text("DEBUG LEVEL: \(DebugLevel.currentLevel.emoji)")
                    Text(DebugLevel.currentLevel.description)
                        .foregroundStyle(Color(color: DebugLevel.currentLevel.color))
                }
            }
            .buttonStyle(.bordered)
        }
        .onReceive(timer, perform: { _ in
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
    
    var tests: [Test] {
        Version.tests + CharacterSet.tests + String.tests + Date.tests + PHP.tests
    }

    public var body: some View {
        NavigationView {
            VStack {
                ColorBarView(colors: .rainbow)
                    .mask {
                        KuditLogo()
                            .padding(2)
                    }
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
                Button {
                    testIsPresented = true
                } label: {
                    ColorBarView(text: "Test", colors: .rainbow)
                        .frame(height: 10)
                }
            }
            .sheet(isPresented: $testIsPresented) {
                NavigationView {
                    TestsListView(tests: tests)
                        .toolbar {
                            Button("Dismiss") {
                                testIsPresented = false
                            }
                        }
                }
            }
            .navigationTitle("Kudit Frameworks")
            .toolbar {
                KuditConnectMenu()
                KuditConnectMenu {
                    Text("Single item")
                }
                KuditConnectMenu(additionalMenus:  {
                    Section("Example Sub-section") {
                        Text("Additional stuff")
                    }
                })
                KuditConnectMenu {
                    Text("Custom label call")
                } label: {
                    Label("Menu Test", systemImage: "star.fill")
                }
            }
        }
#if !os(macOS)
        .navigationViewStyle(.stack)
#endif
    }
}
#endif
