import SwiftUI
#if canImport(KuditFrameworks) // since this is needed in XCode but is unavailable in Playgrounds.
import KuditFrameworks
#endif
#if canImport(Device)
import Device
#endif
#if canImport(ParticleEffects)
import ParticleEffects
#endif

struct TimeClockView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = -1
    @ObservedObject var debugLevel = ObservableDebugLevel.shared
    @State var particleSystem = ParticleSystem<StringConfiguration>(center: .init(x: 0, y: 0.4), behavior: ParticleBehavior(
        birthRate: .frequent,
        lifetime: .brief,
        fadeOut: .lengthy,
        emissionAngle: 360.0,
        spread: .complete,
        initialVelocity: .slow,
        acceleration: .sun,
        blur: .none
    ))
    var body: some View {
        TimelineView(.animation) { context in
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
            .overlay {
                let _ = {
                    let pos = (sin(context.date.timeIntervalSinceReferenceDate) + 1) / 2
                    self.particleSystem.center.x = pos
                }()
                ParticleSystemView(particleSystem: particleSystem) {
                    StringConfiguration(string: "k", coloring: .rainbow)
                }
                .font(.caption.bold())
                .frame(size: 400)
                .background(.clear)
            }
        }
        .onReceive(timer, perform: { _ in
            //debug("updating \(time)")
            time = PHP.time()
        })
    }
}

public struct KuditFrameworksTestView: View {
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
            if .isOS(.tvOS) {
                KuditConnectMenu()
            }
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
            } label: {
                KuditConnect.defaultKuditConnectLabel
            }
#elseif os(tvOS)
            // show as inline menu rather than menu bar
#elseif os(macOS)
            ToolbarItemGroup(placement: .automatic) {
                menus
            }
#else
            ToolbarItemGroup(placement: .topBarTrailing) { // .automatic doesn't work on iPhone 7
                menus
            }
#endif
        }
        .scrollWrapper()
        .navigationWrapper()
    }
}

#Preview("KuditFrameworks") {
    KuditFrameworksTestView()
}
