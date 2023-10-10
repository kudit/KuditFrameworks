//
//  KuditConnect.swift
//  Shout It
//
//  Created by Ben Ku on 10/4/23.
//

/**
 https://getstream.io/blog/using-swiftui-effects-library-how-to-add-particle-effects-to-ios-apps/
 
 https://github.com/GetStream/effects-library
 */

import SwiftUI
import StoreKit
// https://github.com/devicekit/DeviceKit
import DeviceKit
// https://swiftuirecipes.com/blog/send-mail-in-swiftui

// TODO: Build these out with special functions.  Named types to keep things clear and consistent.
typealias HTML = String
extension HTML {
    /// Cleans the HTML content to ensure this isn't just a snippet of HTML and includes the proper headers, etc.
    var cleaned: HTML {
        var cleaned = self
        if !cleaned.contains("<body>") {
            cleaned = """
<body>
\(cleaned)
</body>
"""
        }        
        if !cleaned.contains("<html>") {
            cleaned = """
<html>
\(cleaned)
</html>
"""
        }  
        return cleaned
    }
    /// Generate an NSAttributedString from the HTML content enclosed
    var attributedString: NSAttributedString {
        let cleaned = self.cleaned
        let data = Data(cleaned.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return NSAttributedString(string: cleaned)
    }
}
typealias Version = String
typealias MySQLDate = String // in the future, convert to actual date?  Support conversion to Date object?
struct KuditFAQ: Codable, Identifiable {
    var question: String
    var answer: HTML
    var category: String
    var minversion: Version? // could be null
    var maxversion: Version? // could be null
    var updated: MySQLDate
    var key: String { // TODO: Is this still needed?
        return "kuditConnectAlertShown:\(question)"
    }
    var id: String {
        question
    }
    func answerHTML(textColor: Color) -> HTML {
        var debugHTML = """
 <footer>(\(minversion ?? "n/a"),\(maxversion ?? "n/a")) \(updated) text: \(textColor.cssString)</footer>
"""
//        debug(debugHTML, level: .DEBUG)
        if false && DebugLevel.currentLevel != .DEBUG {
            debugHTML = ""
        }
        return """
 <html><head><link rel="stylesheet" type="text/css" href="\(KuditConnect.kuditAPIURL)/styles.css?lastUpdate=\(updated)" /></head><body style="font-family: -apple-system;color: \(textColor.cssString);">\(answer)\(debugHTML)</body></html>
"""
    }
}
extension [KuditFAQ] {
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

import UIKit
struct HTMLView: UIViewRepresentable {
    let html: HTML
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            uiView.isEditable = false
            uiView.attributedText = html.attributedString
        }
    }
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let label = UITextView()
        return label
    }
}

struct KuditConnectFAQ: View {
    @Environment(\.colorScheme) var colorScheme
    var faq: KuditFAQ
    var body: some View {
        HTMLView(html: faq.answerHTML(textColor: colorScheme == .dark ? .white : .black))
            .padding()
            .navigationTitle(faq.question)
    }
}
// TODO: Add searching and pull to refresh to FAQs
struct KuditConnectFAQs: View {
    @Environment(\.dismiss) var dismiss
    var selectedFAQ: String? // TODO: allow setting this to automatically navigate to the selected FAQ
    var faqs: [KuditFAQ]
    var body: some View {
        NavigationView {
            List {
                let categories = faqs.categories 
                ForEach(categories, id: \.self) { category in
                    Section(category) {
                        ForEach(faqs.filter { $0.category == category }) { faq in
                            NavigationLink {
                                KuditConnectFAQ(faq: faq)                            
                            } label: {
                                Text(faq.question)
                            }
                        }
                    }
                }
                // TODO: add in section to contact support
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

public class KuditConnect: ObservableObject {
    static var shared = KuditConnect()
    
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
        if identifier.components(separatedBy: ".").last == "KuditFramework" {
            identifier = "com.unknown.unknown" // for testing
        }
        let version = Application.main.version
        let urlString = "\(Self.kuditAPIURL)/\(api).php?identifier=\(identifier.urlEncoded)&version=\(version.urlEncoded)\(info)&kcVersion=\(Self.kuditConnectVersion)"
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
        let apiURLString = apiURLString("faq", info: info)

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
            let string = try await loadDataFromAPI("faqs")
            let wrapper = try KCWrapper(fromJSON: string)
            main {
                self.faqs = wrapper.faqs
                debug("Kudit Connect FAQs updated (found \(self.faqs.count))")
            }
        } catch {
            debug("Kudit Connect: Unable to load FAQs from server: \(String(describing: error))", level: .ERROR)
        }
    }
    
    @Published var faqs: [KuditFAQ] // TODO: have a way of loading on demand
    
    @Published public var customizeMessageBody: (String) -> String = {$0} // TODO: Add ability to add files and photos?
    
    @Published var supportEmailData = ComposeMailData(subject: "Unspecified", recipients: [], message: "Overwrite", attachments: nil)
    
    public static var supportEmail = "support+\(Application.main.appIdentifier)@kudit.com"
    public static var supportEmailSubject = "App Feedback for \(Application.main.name)"
    public var appInformation: String {
        """
  Application: \(Application.main.name)
  Version: \(Application.main.version)
  Previously run versions: \(Application.main.versionsRun.joined(separator: ", "))
  Identifier: \(Application.main.appIdentifier)
  iCloud: \(Application.main.iCloudIsEnabled ? "Enabled" : "Disabled")
  Device: \(Device.current.description)
  Screen Ratio: \(Device.current.screenRatio)
  System: \(Device.current.systemName ?? "Unavailable") \(Device.current.systemVersion ?? "Unknown")
  Battery Level: \(String(describing: Device.current.batteryLevel))
  Available Storage: \(Device.volumeAvailableCapacityForOpportunisticUsage?.description ?? "Unknown")
  KuditFrameworks version: \(Application.main.frameworkVersion)
  KuditConnect version: \(Self.kuditConnectVersion)
  """
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
    
    public static let kuditAPIURL = "https://www.kudit.com/api"
    public static let kuditConnectVersion = "3.0"
    
    // https://www.kudit.com/api/kudos.php?identifier=com.kudit.BROWSERTEST&version=1.2.3&kcVersion=3.2.1
    // Returns "SUCCESS"
    
    /// Send Kudos to server for this app
    public func sendKudos() async -> String {
        let displayName = Application.main.name
        do {
            let string = try await loadDataFromAPI("kudos", info: "&info=\(customizeMessageBody(appInformation).urlEncoded)")
            if string != "SUCCESS" {
                throw CustomError("Unable to send Kudos :-(", level: .ERROR)
            }
            return "Thank you so much for sending kudos to the \(displayName) team!  It means a lot to them.  Please rate the app and leave a review to really help the team out!"
        } catch {
            debug("Unable to send Kudos!  Error: \(String(describing: error))", level: .ERROR)
            return "There was a problem sending your kudos to the \(displayName) team!  Please try again later."
        }
    }
}

public struct KuditConnectMenu<Content: View>: View {
    public var additionalMenus: () -> Content
    
    public init(customizeMessageBody: @escaping (String) -> String = {$0}, @ViewBuilder additionalMenus: @escaping () -> Content = { EmptyView() }) {
        KuditConnect.shared.customizeMessageBody = customizeMessageBody
        self.additionalMenus = additionalMenus
    }
        
    @Environment(\.openURL) var openURL

    @State private var showFAQs = false
    @State private var showMailView = false
    @State private var kudosMessageText = "Sending your kudos to the team..."
    @State private var showKudos = false
    @State private var isKudosScreenVisible = false
    public var body: some View {
        Menu {
            Text("Version \(Application.main.version)")
            additionalMenus()
            Button(action: {
                showFAQs = true
            }) {
                Label("Help & FAQs", systemImage: "questionmark.circle")
            }
            Button(action: {
                Vibration.light.vibrate()
                // Generate support email when button pressed but not before
                contactSupport()
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
            Button(action: {
                Vibration.light.vibrate()
                showKudos.toggle()
                Task {
                    // Use kudos messages result in KudosView - have a binding so can change/update
                    kudosMessageText = await KuditConnect.shared.sendKudos()
                    Vibration.heavy.vibrate()
                }
            }) {
                Label("Send Us Kudos", systemImage: "hands.sparkles") // hand.thumbsup
            }
//            Text("KuditFrameworks v\(Application.main.frameworkVersion)")
            Text("KuditConnect v\(KuditConnect.kuditConnectVersion)")
            //                    Button("Add Passbook Pass", action: {})
        } label: {
            Label("KuditConnect support menu", systemImage: "questionmark.bubble")
            // TODO: Try with KuditLogo shape?
        }
        .sheet(isPresented: $showFAQs) {
            KuditConnectFAQs(faqs: KuditConnect.shared.faqs)
        }
        /// Kudos view
        .fullScreenCover(isPresented: $showKudos) {
            Group {
                if isKudosScreenVisible {
                    KudosView(messageText: $kudosMessageText, isKudosScreenVisible: $isKudosScreenVisible)
                    .onDisappear {
                        // dismiss the FullScreenCover - how does making this invisible making it disappear?
                        showKudos = false
                    }
                }
            }
            .onAppear {
                isKudosScreenVisible = true
            }
        }
        .transaction({ transaction in
            // disable the default FullScreenCover animation
            transaction.disablesAnimations = true
            // add custom animation for presenting and dismissing the FullScreenCover
            transaction.animation = .linear(duration: 0.2)
        })

    }
    
    // MARK: - FAQs

    // MARK: - Support Email
    public func contactSupport() {
        openURL(KuditConnect.shared.generateSupportEmailLink())
    }
}
// MARK: - Kudos
#if canImport(EffectsLibrary)
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

@available(iOS 16.0, *)
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
                if #available(iOS 16, *) {
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
        if #available(iOS 16.4, *) {
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
                KuditConnectMenu(additionalMenus:  {
                    Section("Example Sub-section") {
                        Toggle("Toggle", isOn: $toggleOn)
//                        Toggle("Left-handed mode", systemImage: toggleOn ? "hand.point.left.fill" : "hand.point.left", isOn: $toggleOn)
                        Text("Additional stuff")
                    }
                })
            }
        }

    }
}

struct KCTestView_Previews: PreviewProvider {
    static var previews: some View {
        KCTestView()
            .previewDisplayName("KC Test")
        KuditConnectFAQs(faqs: KuditConnect.shared.faqs)
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
