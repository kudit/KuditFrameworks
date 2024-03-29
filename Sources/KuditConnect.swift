//
//  KuditConnect.swift
//  Shout It
//
//  Created by Ben Ku on 10/4/23.
//

/**
 https://getstream.io/blog/using-swiftui-effects-library-how-to-add-particle-effects-to-ios-apps/
 
 https://github.com/GetStream/effects-library
 
 Example usage with additional menu items:
 
KuditConnectMenu {
    Section {
        Toggle("Left-handed mode", systemImage: manager.leftHandedMode ? "hand.point.left.fill" : "hand.point.left", isOn: $manager.leftHandedMode)
        if ExternalDisplayManager.shared.displayConnected {
            ExternalDisplayManager.shared.orientationPicker
                .pickerStyle(.menu)
        }
    }
}
 */


import SwiftUI
import StoreKit
// https://github.com/devicekit/DeviceKit
import Device
// https://swiftuirecipes.com/blog/send-mail-in-swiftui

// MARK: - FAQs
import Ink
public typealias MySQLDate = String // in the future, convert to actual date?  Support conversion to Date object?
public struct KuditFAQ: Codable, Identifiable {
    public var question: String
    public var answer: HTML
    public var category: String
    public var minversion: Version? // could be null
    public var maxversion: Version? // could be null
    public var updated: MySQLDate
    public var key: String { // TODO: Is this still needed?
        return "kuditConnectAlertShown:\(question)"
    }
    public var id: String {
        question
    }
    public func visible(in version: Version) -> Bool {
        if let minversion, minversion > version {
            return false
        }
        if let maxversion, maxversion < version {
            return false
        }
        return true
    }
    public func answerHTML(textColor: Color) -> HTML {
        var debugHTML = """
 <footer>(\(minversion?.rawValue ?? "n/a"),\(maxversion?.rawValue ?? "n/a")) \(updated) text: \(textColor.cssString)</footer>
"""
//        debug(debugHTML, level: .DEBUG)
        if DebugLevel.currentLevel != .DEBUG {
            debugHTML = ""
        }
        let parser = MarkdownParser()
        let answerHTML = parser.html(from: answer)
        // use web style so that we can update without updating code.
        return """
 <html><head><meta name="viewport" content="width=device-width" /><link rel="stylesheet" type="text/css" href="\(KuditConnect.kuditAPIURL)/styles.css?version=\(Application.main.frameworkVersion)&lastUpdate=\(updated)" /></head><body style="font-family: -apple-system;color: \(textColor.cssString);">\(answerHTML)\(debugHTML)</body></html>
"""
    }
}
public extension [KuditFAQ] {
    var categories: [String] {
        var categories = [String]()
        for faq in self {
            if !categories.contains(faq.category) {
                categories.append(faq.category)
            }
        }
        return categories.sorted()
    }
}

struct KuditConnectFAQ: View {
    @Environment(\.colorScheme) var colorScheme
    var faq: KuditFAQ
    var body: some View {
#if canImport(WebKit) && canImport(UIKit)
        HTMLView(htmlString: faq.answerHTML(textColor: colorScheme == .dark ? .white : .black))
            .navigationTitle(faq.question)
#else
        Text(faq.answer)
#endif
    }
}
// TODO: Add searching and pull to refresh to FAQs
struct KuditConnectFAQs: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    var selectedFAQ: String? // TODO: allow setting this to automatically navigate to the selected FAQ
    @ObservedObject var connect: KuditConnect
    var body: some View {
        NavigationView {
            List {
                let categories = connect.faqs.categories 
                ForEach(categories, id: \.self) { category in
                    Section(category) {
                        ForEach(connect.faqs.filter { $0.category == category }) { faq in
                            NavigationLink {
                                KuditConnectFAQ(faq: faq)                            
                            } label: {
                                Text(faq.question)
                            }
                        }
                    }
                }
                Section("Question not answered?") {
                    Button("Contact Support") {
                        KuditConnect.shared.contactSupport(openURL)
                    }
                }
                // TODO: add in section to contact support
                Text("\(Application.main.name) v\(Application.main.version) © \(String(Date().year)) Kudit LLC All Rights Reserved.\nRead our [Privacy Policy](https://kudit.com/privacy.php) or [Terms of Use](https://kudit.com/terms.php).\n\nOpen Source projects used include [DeviceKit](https://github.com/devicekit/DeviceKit), [Effects Library](https://github.com/GetStream/effects-library), and [Ink](https://github.com/JohnSundell/Ink).\(connect.additionalLegalInfo)")
                    .font(.footnote)
            }
            .refreshable {
                await KuditConnect.shared.loadFromServer()
            }
            .navigationTitle("FAQs")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
/*
// TODO: filter FAQs based on my current app version and search terms
#warning missing search bar!
- (NSFetchedResultsController*) _fetchedResultsController {
    if (!_fetchedResultsController) {
        // set up fetch request
        NSManagedObjectContext *context = _faqData.mainContext;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FAQ"];
        NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
        NSMutableArray *predicates = [NSMutableArray array];
        [predicates addObject:[NSPredicate predicateWithFormat:@"(minversion = nil OR minversion <= %@)", version]];
        [predicates addObject:[NSPredicate predicateWithFormat:@"(maxversion = nil OR maxversion >= %@)", version]];
        if (_searchString && ![_searchString isEqualToString:@""]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"(question contains[cd] %@ OR answer contains[cd] %@)", _searchString, _searchString]];
        }
        fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"lastUpdated" ascending:NO]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:@"category"
                                                                                   cacheName:@"KuditFAQs"];
        [_fetchedResultsController performFetch];
        _fetchedResultsControllerDelegate = [KuditFetchControllerDelegate fetchControllerDelegateWithView:self.tableView];
        _fetchedResultsController.delegate = _fetchedResultsControllerDelegate;
    }
    return _fetchedResultsController;
}

 // TODO: Enable pull to refresh
    // TODO: allow cross-linking to other FAQs
 // TODO: Trap mailto links and convert to internal action to present mail controller?
*/

/// For presenting KuditConnect menu information.  Usually won't need, but if you want to customize the email message, modify this shared object.  Example to append data:
///  KuditConnect.shared.customizeMessageBody = { original in original + "\nMy New Data" }
// TODO: Have option to include data as file attachment (for Shout It, Score, Halloween Tracker)
// MARK: - KuditConnect model
public class KuditConnect: ObservableObject {
    public static var shared = KuditConnect()
    
    public init() {
        // TODO: Load FAQs
        self.faqs = [KuditFAQ(question: "Loading FAQs…", answer: "Please connect to the internet to make sure the most current FAQs can load from the server.", category: "Standby", minversion: nil, maxversion: nil, updated: Date().mysqlDateTime)]
        // TODO: NEXT: Trigger URL asynchronous loading to update FAQs value and store using SwiftData
        Task {
            await loadFromServer()
        }
    }
    
    func apiURLString(_ api: String, info: String = "") -> String {
        var identifier = Application.main.appIdentifier
        // when running in preview, identifier may be: swift-playgrounds-dev-previews.swift-playgrounds-app.hdqfptjlmwifrrakcettacbhdkhn.501.KuditFramework
        let lastComponent = identifier.components(separatedBy: ".").last
        if lastComponent == "KuditFramework" || lastComponent == "KuditFrameworksApp" {
            identifier = "com.unknown.unknown" // for testing
        }
        let version = Application.main.version
        var urlString = "\(Self.kuditAPIURL)/\(api).php?identifier=\(identifier.urlEncoded)&version=\(version)&kcVersion=\(Self.kuditConnectVersion)\(info)"
        // limit to 2000 characters to prevent URI overflow
        urlString = String(urlString.prefix(2000))
        debug("Kudit Connect: API URL: \(urlString)", level: .NOTICE)
        return urlString
    }
    
    enum KuditAPIError: Error {
        /// Throw when the URL is malformed
        case malformedURL(String)
                
        /// Throw when the network is unavailable
        case networkUnavailable
        
        /// Throw when the API server is unreachable
        case serverUnreachable
        
        /// Throw when there's a server error (with HTTP error code)
        case serverError(Int)
        
        /// Throw when the server data cannot be read as a String
        case dataError
    }
    
    /// This should be run in a background thread to get API data from the server.
    func loadDataFromAPI(_ api: String, info: String = "") async throws -> String {
        let apiURLString = apiURLString(api, info: info)

        // Convert string to URL (should never fail!)
        guard let url = URL(string:apiURLString) else {
            debug("Unable to convert string to URL: \(apiURLString)", level: .ERROR)
            throw KuditAPIError.malformedURL(apiURLString)
        }
        
        // Create URL request
        let urlRequest = URLRequest(url: url)

        // Fetch data from server
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status code exists (should nearly always pass)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            debug("No status code in HTTP response.  Possibly offline?: \(String(describing: response))", level: .ERROR)
            throw KuditAPIError.networkUnavailable
        }
        
        // check status code
        guard statusCode == 200 else {
            throw KuditAPIError.serverError(statusCode)
        }
        
        // convert result data to string (since this will always be a String (either "SUCCESS" or a JSON string)
        guard let results = String(data: data, encoding: .utf8) else {
            debug("Unable to parse string out of data: \(String(describing: data))", level: .ERROR)
            throw KuditAPIError.dataError
        }
        return results
    }
    
    struct KCWrapper: Codable {
        var faqs: [KuditFAQ]
    }
    func loadFromServer() async {
        do {
            let string = try await loadDataFromAPI("faq")
            let wrapper = try KCWrapper(fromJSON: string)
            // filter FAQs based on what the actual app version is
            let filtered = wrapper.faqs.filter { $0.visible(in: Application.main.version) }
            main {
                self.faqs = filtered
                debug("Kudit Connect FAQs updated (found \(KuditConnect.shared.faqs.count))", level: .NOTICE)
            }
        } catch {
            debug("Kudit Connect: Unable to load FAQs from server: \(String(describing: error))", level: .ERROR)
        }
    }
    
    @Published public var faqs: [KuditFAQ] // TODO: have a way of loading on demand
    
    public var additionalLegalInfo = "" // use to add any copyright or license information
    
    // MARK: - Support Email
    @Published public var customizeMessageBody: (String) -> String = {$0} // TODO: Add ability to add files and photos?
    
    @Published var supportEmailData = ComposeMailData(subject: "Unspecified", recipients: [], message: "Overwrite", attachments: nil)
    
    public static var supportEmail = "support+\(Application.main.appIdentifier)@kudit.com"
    public static var supportEmailSubject = "App Feedback for \(Application.main.name)"
    public var appInformation: String {
        var screenResolution = "Screen Resolution: "
        if let screen = Device.current.screen, let resolution = screen.resolution {
            screenResolution += " \(resolution.0)x\(resolution.1)\n"
        } else {
            screenResolution = ""
        }
        var infostring = """
  Application: \(Application.main)
  Device: \(Device.current.description)\(Application.inPlayground ? " - PLAYGROUND" : "")
  \(screenResolution)System: \(Device.current.systemName ?? "Unavailable") \(Device.current.systemVersion ?? "Unknown")

  """
        if let battery = Device.current.battery {
            infostring +=
        """
          Battery Level: \(battery.description)

          """
        }
#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
    infostring += """
  Available Storage: \(Device.current.volumeAvailableCapacityForOpportunisticUsage?.byteString ?? "Unknown")

  """
#endif
        return infostring
    }
    
    public func generateSupportEmail() -> String {
        let body = """
Enter feedback, questions, or comments:







Please provide your feedback above.
------------- App Information -------------
This section is to help us properly route your feedback and help troubleshoot any issues.
\(appInformation)

------------- App Information -------------

"""
/*
 NSString *emailBody = [NSString stringWithFormat:@"%@<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />Please provide your feedback above.<hr />This section is to help us properly route your feedback and help troubbleshoot any issues.  Please do not modify or remove.<br /><br /><blockquote>%@</blockquote>", firstProperty, [properties componentsJoinedByString:@"<br />"]];
*/
        return customizeMessageBody(body)
    }
    
    func generateSupportEmailLink() -> URL {
        supportEmailData = ComposeMailData(
            subject: Self.supportEmailSubject,
            recipients: [Self.supportEmail],
            message: generateSupportEmail(),
            attachments: nil)
        return supportEmailData.mailtoLink
    }

    public func contactSupport(_ openURL: OpenURLAction) {
        openURL(generateSupportEmailLink())
    }

    public static let kuditAPIURL = "https://www.kudit.com/api"
    public static let kuditConnectVersion: Version = "3.0"
    
    // https://www.kudit.com/api/kudos.php?identifier=com.kudit.BROWSERTEST&version=1.2.3&kcVersion=3.2.1
    // Returns "SUCCESS"
    
    /// Send Kudos to server for this app
    public func sendKudos() async -> String {
        let displayName = Application.main.name
        do {
            let string = try await loadDataFromAPI("kudos", info: "&info=\(customizeMessageBody(appInformation).urlEncoded)")
            if string != "SUCCESS" {
                throw CustomError("Unable to send Kudos :-( Server responded: \(string)", level: .ERROR)
            }
            return "Thank you so much for sending kudos to the \(displayName) team!  It means a lot to them.  Please rate the app and leave a review to really help the team out!"
        } catch {
            debug("Unable to send Kudos!  Error: \(String(describing: error))", level: .ERROR)
            return "There was a problem sending your kudos to the \(displayName) team!  Please try again later."
        }
    }
}

#if !os(watchOS) && !os(tvOS)
extension KuditConnect {
    public static let defaultKuditConnectLabel = Label("KuditConnect support menu", systemImage: "questionmark.bubble")
}
// additional initializers for single and zero arguments.
public extension KuditConnectMenu where Content == EmptyView, LabelView == Label<Text, Image> {
    init() {
        self.init {
            EmptyView()
        }
    }
}
public extension KuditConnectMenu where LabelView == Label<Text, Image> {
    // since label added and just like view, added single parameter init so existing trailing closure syntax will work.
    //  = { EmptyView() }
    init(@ViewBuilder additionalMenus: @escaping () -> Content) {
        self.init(additionalMenus: additionalMenus) {
            KuditConnect.defaultKuditConnectLabel 
        }
    }
}
public struct KuditConnectMenu<Content: View, LabelView: View>: View {
    public var additionalMenus: () -> Content
    public var label: () -> LabelView
            
    public init(@ViewBuilder additionalMenus: @escaping () -> Content, @ViewBuilder label: @escaping () -> LabelView) {
        self.additionalMenus = additionalMenus
        self.label = label
    }
            
    @Environment(\.openURL) var openURL

    @State private var showFAQs = false
    @State private var showMailView = false
    @State private var kudosMessageText = "Sending your kudos to the team..."
    @State private var showKudos = false
    @State private var isKudosScreenVisible = false
    public var body: some View {
        Menu {
            additionalMenus()
            Section("Version \(Application.main.version)" + (DebugLevel.currentLevel == .DEBUG ? "  DEBUG" : "")) {
                Button(action: {
                    showFAQs = true
                }) {
                    Label("Help & FAQs", systemImage: "questionmark.circle")
                }
                Button(action: {
                    Vibration.light.vibrate()
                    // Generate support email when button pressed but not before
                    KuditConnect.shared.contactSupport(openURL)
                    //                showMailView = true
                }) {
                    Label("Contact Support", systemImage: "envelope")
                }
                //            .disabled(!MailView.canSendMail)
                //            .sheet(isPresented: $showMailView) {
                //                MailView(data: $supportEmailData) {_ in
                //                    print("MailViewCallback")
                //                }
                //            }
                /*            Button(action: {
                 Vibration.medium.vibrate()
                 }) {
                 // Button-triggered reviews are not allowed by App Store
                 Label("Leave a Review", systemImage: "star")
                 }*/
                /*            Button(action: {
                 Vibration.heavy.vibrate()
                 }) {
                 Label("Share App With Friends", systemImage: "square.and.arrow.up")
                 }*/
//#if canImport(UIKit)
                Button(action: {
                    Vibration.light.vibrate()
                    
                    // TODO: Double check and polish animations
                    var transaction = Transaction(animation: .linear)
                    transaction.disablesAnimations = true
                    // add custom animation for presenting and dismissing the FullScreenCover
                    transaction.animation = .linear(duration: 0.2)
                    
                    // disable the default FullScreenCover animation
                    withTransaction(transaction) {
                        showKudos.toggle()
                    }
                    
                    Task {
                        // Use kudos messages result in KudosView - have a binding so can change/update
                        kudosMessageText = await KuditConnect.shared.sendKudos()
                        Vibration.heavy.vibrate()
                    }
                }) {
                    Label("Send Us Kudos", systemImage: "hands.sparkles") // hand.thumbsup
                }
//#endif
                //            Text("KuditFrameworks v\(Application.main.frameworkVersion)")
                //Text("KuditConnect v\(KuditConnect.kuditConnectVersion)")
                //                    Button("Add Passbook Pass", action: {})
            }
        } label: {
            label()
        }
        .sheet(isPresented: $showFAQs) {
            KuditConnectFAQs(connect: KuditConnect.shared)
        }
//#if canImport(UIKit)
        /// Kudos view
        .fullScreenCover(isPresented: $showKudos) {
            Group {
                if isKudosScreenVisible {
                    KudosView(messageText: $kudosMessageText, isKudosScreenVisible: $isKudosScreenVisible)
                    .onDisappear {
                        // dismiss the FullScreenCover - how does making this invisible making it disappear?

                        var transaction = Transaction(animation: .linear)
                        transaction.disablesAnimations = true
                        // add custom animation for presenting and dismissing the FullScreenCover
                        transaction.animation = .linear(duration: 0.2)

                        // disable the default FullScreenCover animation
                        withTransaction(transaction) {
                            showKudos = false
                        }
                    }
                }
            }
            .onAppear {
                isKudosScreenVisible = true
            }
        }
//#endif
    }
}
// MARK: - Kudos
#if canImport(EffectsLibrary) && canImport(UIKit)
import EffectsLibrary
private struct FancyView: View {
    var body: some View {
        ConfettiView(config: ConfettiConfig(
            content: [
                .emoji("😊", 1),
                .emoji("👍", 1),
                .emoji("☺️", 1),
                .emoji("👏", 1),
                .emoji("🙌", 1),
            ], backgroundColor: .clear, intensity: .high, lifetime: .long, initialVelocity: .medium, spreadRadius: .medium, emitterPosition: .center, clipsToBounds: false, fallDirection: .upwards))
    }
}
#else
private struct FancyView: View {
    var body: some View {
        Color.yellow.opacity(0.2)
    }
}
#endif

@available(macOS 13.0, iOS 16.0, tvOS 20.0, *)
private struct ReviewButton: View {
    @Environment(\.requestReview) var requestReview
    var action: () -> Void
    var body: some View {
        Button("Okay") {
            requestReview()
            action()
        }
    }
}

private struct KudosOverlayView: View {
    @Binding var messageText: String
    @Binding var isKudosScreenVisible: Bool
    var body: some View {
        ZStack {
            FancyView()
            VStack {
                // TODO: Have this dynamic so we can change after confirming the kudos were sent?  Set to "Sending kudos..." and then change to this message once sent and have option to show error message which automatically generates a bug report.
                Text(messageText)
                    .italic()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                if #available(iOS 16, macOS 13.0, tvOS 20.0, *) {
                    ReviewButton {
                        isKudosScreenVisible = false
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Okay") {
                        // hide view and then dismiss
                        isKudosScreenVisible = false
                    }
                    .buttonStyle(.bordered)
                }
            }.padding().background(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)).fill(.regularMaterial)).padding()
        }
    }
}
struct KudosView: View {
    @Binding var messageText: String
    @Binding var isKudosScreenVisible: Bool
    var body: some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            KudosOverlayView(messageText: _messageText, isKudosScreenVisible: _isKudosScreenVisible)
            .presentationBackground(.black.opacity(0.4))
                // .yellow.opacity(0.2))
        } else {
            // Fallback on earlier versions
            KudosOverlayView(messageText: _messageText, isKudosScreenVisible: _isKudosScreenVisible)
        }
    }
}

private struct KCTestView: View {
    @State var toggleOn = false
    var body: some View {
        NavigationView {
            List(1..<100, id: \.self) { index in
                Text("Row \(index)")
                    .foregroundStyle(toggleOn ? .green : .yellow)
            }
            .toolbar {
                // Add the menu button
                KuditConnectMenu()
                KuditConnectMenu {
                    Text("Single item")
                }
                KuditConnectMenu(additionalMenus:  {
                    Section("Example Sub-section") {
                        Toggle("Toggle", isOn: $toggleOn)
//                        Toggle("Left-handed mode", systemImage: toggleOn ? "hand.point.left.fill" : "hand.point.left", isOn: $toggleOn)
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

    }
}

struct KCTestView_Previews: PreviewProvider {
    static var previews: some View {
        KCTestView()
            .previewDisplayName("KC Test")
        KuditConnectFAQs(connect: KuditConnect.shared)
            .previewDisplayName("FAQs")
        KuditConnectFAQ(faq: KuditConnect.shared.faqs.first!)
            .previewDisplayName("FAQ")
        KudosView(messageText: .constant("Hello world \(Application.main.name) test message text"), isKudosScreenVisible: .constant(true))
            .previewDisplayName("Kudos")
    }
}
//#Preview("Kudos View") {
//    if #available(iOS 16.4, *) {
//        KudosView(isKudosScreenVisible: .constant(true))
//    } else {
//        // Fallback on earlier versions
//        Text("KuditConnect Unavailable")
//    }
//}
//
//// MARK: - Preview
//#Preview("KuditConnect") {
//    KCTestView()
//}
#endif
