import SwiftUI
#if canImport(KuditFrameworks) // since this is needed in XCode but is unavailable in Playgrounds.
import KuditFrameworks
#endif
#if canImport(Device)
import Device
#endif

struct TimeClockView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = -1
    @ObservedObject var debugLevel = ObservableDebugLevel()
    var body: some View {
        VStack {
            Text("Unix time: \(time)")
            Button {
                DebugLevel.currentLevel++
            } label: {
                HStack {
                    Text("DEBUG LEVEL: \(debugLevel.value.emoji)")
                    Text(debugLevel.value.description)
                        .foregroundStyle(Color(color: debugLevel.value.color))
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
    
    @ViewBuilder
    var menus: some View {
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
    
    public var body: some View {
        VStack {
            Button {
                testIsPresented = true
            } label: {
                HStack {
                    ColorBarTestView(colors: .rainbow)
                        .mask {
                            KuditLogo()
                        }
                        .frame(size: 44)
                    Text("Run Tests")
                        .font(.title)
                }
                .frame(height: 60)
            }
            Text("Hello, Kudit world!")
            TimeClockView()
            ApplicationInfoView()
            Group {
                CurrentDeviceInfoView(device: Device.current, includeStorage: false, debug: true)
                    .padding()
            }.background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.quaternary)
            }
            NavigationLink {
                ColorTestView()
            } label: {
                ColorBarTestView(text: "Color Tests", colors: .rainbow)
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.green)
                    }
            }
            .frame(maxHeight: 44)
            NavigationLink {
                VibrationTestsView()
                    .scrollWrapper()
            } label: {
                Text("Vibration Tests")
            }
        }
        .padding()
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
            #if os(watchOS)
            Menu {
                menus
            } label: { KuditConnect.defaultKuditConnectLabel
            }
            #else
            menus
            #endif
        }
        .scrollWrapper()
        .navigationWrapper()
    }
}

#Preview("KuditFrameworks") {
    KuditFrameworksTestView()
}
