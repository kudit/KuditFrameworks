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
    var name = "Test Application Name"
    var isFirstRun = true
    var version = Version("4.0.0")
    var previouslyRunVersions = [Version("1.0.0"), "1.1.1", "1.2.2", "1.3", "2.0", "3.0.1", "3.1.1", "3.2.1", "3.3", "3.3.1", "3.3.4", "3.3.5", "3.3.6", "3.4", "3.4.1", "3.4.2", "3.4.4", "3.4.5"]
    var appIdentifier = "com.kudit.test.TestApplication"
    var iCloudStatus = CloudStatus.notSupported
}

public struct ApplicationInfoView: View {
    var application: ApplicationViewPresentable
    @State var includeDebugInformation: Bool
    
    // binding so that we can observe changes
    @ObservedObject fileprivate var debugLevel = ObservableDebugLevel()
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
                        .frame(size: 44)
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
            Divider()
            if application.previouslyRunVersions.count > 0 && includeDebugInformation {
                Text("Previously Run Versions: \(application.previouslyRunVersions.map { "v\($0)" }.joined(separator: ", "))")
                .opacity(0.5)
                .font(.caption2)
                .multilineTextAlignment(.center)
            }
            ZStack(alignment: .centerFirstTextBaseline) {
                HStack(spacing: 0) {
                    KuditLogo(weight: 0.5, color: .primary).frame(size: 14)
                    Text(" v").opacity(0.5)
                    Text("\(KuditFrameworks.version)")
                    Spacer()
                    if includeDebugInformation {
                        Text("v").opacity(0.5)   
                        Text("\(KuditConnect.version) ")   
                        Image(symbolName: "questionmark.circle.fill")
                    }
                }
                if application.iCloudStatus != .notSupported || includeDebugInformation {
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
        .foregroundStyle(.primary)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.tint)
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
