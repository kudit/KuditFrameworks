#if canImport(SwiftUI)
import SwiftUI
import Foundation
import Device

extension CloudStatus: SymbolRepresentable {
    public var symbolName: String {
        switch self {
        case .notSupported:
            return "icloud.slash.fill"
        case .available:
            return "checkmark.icloud.fill"
        case .unavailable:
            return "xmark.icloud.fill"
        }
    }
}

public protocol ApplicationViewPresentable {
    var name: String { get }
    var isFirstRun: Bool { get }
    var version: Version { get }
    var previouslyRunVersions: [Version] { get }
    var appIdentifier: String { get }
    var iCloudStatus: CloudStatus { get }
}
extension Application: ApplicationViewPresentable {}
struct MockApplication: ApplicationViewPresentable {
    static var globalVersionCount = 0
    var name = "Test Application Name"
    var isFirstRun = true
    var version = Version("4.0.0")
    var previouslyRunVersions: [Version]
    var appIdentifier = "com.kudit.test.TestApplication"
    var iCloudStatus = CloudStatus.notSupported
    init(name: String = "Test Application Name", isFirstRun: Bool = true, version: Version? = nil, previouslyRunVersions: [Version]? = nil, appIdentifier: String = "com.kudit.test.TestApplication", iCloudStatus: CloudStatus = CloudStatus.notSupported) {
        self.name = name
        self.isFirstRun = isFirstRun
        if let version {
            self.version = version
        } else {
            self.version = Version("4.\(Self.globalVersionCount).0")
            Self.globalVersionCount++
        }
        if let previouslyRunVersions {
            self.previouslyRunVersions = previouslyRunVersions
        } else {
            self.previouslyRunVersions = [Version("1.0.0"), "1.1.1", "1.2.2", "1.3", "2.0", "3.0.1", "3.1.1", "3.2.1", "3.3", "3.3.1", "3.3.4", "3.3.5", "3.3.6", "3.4", "3.4.1", "3.4.2", "3.4.4", "3.4.5"]
        }
        self.appIdentifier = appIdentifier
        self.iCloudStatus = iCloudStatus
    }
}

public struct ApplicationInfoView: View {
    var application: ApplicationViewPresentable
    @State var includeDebugInformation: Bool
    
    // binding so that we can observe changes
    @ObservedObject fileprivate var debugLevel = ObservableDebugLevel.shared
    public init(application: ApplicationViewPresentable = Application.main, includeDebugInformation: Bool = false) {
        self.application = application
        self.includeDebugInformation = includeDebugInformation
    }
    public var body: some View {
        VStack {
            HStack(alignment: .top) {
                if let image = Image.appIcon {
                    image
//                        .antialiased(true) //for smooth edges for scale to fill
                        .interpolation(.high)
                        .resizable()
                    #if os(tvOS)
                        .frame(width: 80, height: 48)
                    #else
                        .frame(size: 44)
                    #endif
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(application.name)")
                        Spacer()
                        if application.isFirstRun {
                            Text("*First Run!*  ")
                                .font(.footnote).foregroundStyle(.background)
                        }
                        Text("v").opacity(0.5)
                        Text("\(application.version)")
                    }
                    if includeDebugInformation {
                        HStack {
                            Text("*\(application.appIdentifier)*")
                                .font(.caption2)
                                .foregroundStyle(.background)
                            Spacer(minLength: 0)
                            Text("\(debugLevel.value.emoji) \(debugLevel.value) ")
                                .font(.footnote)
                                .padding(size: 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color(color: debugLevel.value.color))
                                )
                        }
                    }
                }
            }.font(.headline)
            if includeDebugInformation {
                Divider()
                if application.previouslyRunVersions.count > 0 {
                    Text("Previously Run Versions: \(application.previouslyRunVersions.map { "v\($0)" }.joined(separator: ", "))")
                        .opacity(0.5)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                }
                ZStack(alignment: .centerFirstTextBaseline) {
                    HStack(spacing: 0) {
                        KuditLogo(weight: 0.5, color: .accentColor.contrastingColor).frame(size: 14)
                        Text(" v").opacity(0.5)
                        Text("\(KuditFrameworks.version) (\(KuditConnect.version))")
                        Spacer()
                        if includeDebugInformation {
                            Text("Swift ").opacity(0.5)
                            Text("\(Device.current.swiftVersion)")   
                            Image(symbolName: "swift")
                        }
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Text("iCloud:").opacity(0.5)
                        Image(application.iCloudStatus)
                        Text("\(application.iCloudStatus)")
                    }
                }
            }
        }
        .font(.footnote)
        .padding()
        .foregroundStyle(Color.accentColor.contrastingColor) // since background is tint color, choose a contrasting color for this view regardless of dark mode.
//        .foregroundStyle(.primary)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.isOS(.tvOS) ? AnyShapeStyle(.black) : AnyShapeStyle(.tint))
        }
        .onTapGesture {
            includeDebugInformation.toggle()
        }
    }
}

#Preview {
    VStack {
        ApplicationInfoView(includeDebugInformation: true)
        Divider()
        ApplicationInfoView(application: MockApplication(appIdentifier: "test.swift-playgrounds-dev-previews.swift-playgrounds-app.fflkhjqdpnhdzgdragnnoffbxvye.501.KuditFramework"), includeDebugInformation: true)
        ApplicationInfoView(application: MockApplication(iCloudStatus: .unavailable), includeDebugInformation: true)
        ApplicationInfoView(application: MockApplication(iCloudStatus: .available))
    }.padding()
}
#endif
