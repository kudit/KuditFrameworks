#if canImport(SwiftUI)
import SwiftUI

// https://swiftuirecipes.com/blog/send-mail-in-swiftui

// MARK: - FAQs
import Ink
public struct KuditFAQ: Codable, Identifiable, Sendable {
    public typealias MySQLDate = String // in the future, convert to actual date?  Support conversion to Date object?
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
    @MainActor
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
        // use web style so that we can update without updating code.  charset meta tag necessary for NSAttributedString conversion from HTML.
        return """
 <html><head><meta name="viewport" content="width=device-width" /><meta charset="utf-8" /><link rel="stylesheet" type="text/css" href="\(KuditConnect.kuditAPIURL)/styles.css?version=\(KuditFrameworks.version)&lastUpdate=\(updated)" /></head><body style="font-family: -apple-system;color: \(textColor.cssString);">\(answerHTML)\(debugHTML)</body></html>
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
        let html = faq.answerHTML(textColor: colorScheme == .dark ? .white : .black)
//        let _ = { print("HTML: \(html)") }()
#if canImport(WebKit) && canImport(UIKit) && !os(watchOS) && !os(tvOS)
        HTMLView(htmlString: html)
            .navigationTitle(faq.question)
#else
        // for watchOS & tvOS
        ScrollView {
            let data = Data(html.utf8)
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                Text(AttributedString(attributedString))
            } else {
                Text(faq.answer)
            }
        }
        .navigationTitle(faq.question)
#endif
    }
}

import ParticleEffects // for version string
import Device

// TODO: Add searching and pull to refresh to FAQs
struct KuditConnectFAQs: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    var selectedFAQ: String? // TODO: allow setting this to automatically navigate to the selected FAQ
    @ObservedObject var connect: KuditConnect
    var body: some View {
        List {
            ApplicationInfoView()
                .listRowInsets(.zero)
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
            Section("Device Information") {
                CurrentDeviceInfoView(device: Device.current, debug: Application.DEBUG)
            }
#if !os(tvOS) // tvOS doesn't support email TODO: Figure out way to do this
            Section("Question not answered?") {
                Button("Contact Support") {
                    KuditConnect.shared.contactSupport(openURL)
                }
            }
#endif
            Text("\(Application.main.name) v\(Application.main.version) © \(String(Date().year)) Kudit LLC All Rights Reserved.\nRead our [Privacy Policy](https://kudit.com/privacy.php) or [Terms of Use](https://kudit.com/terms.php).\n\nOpen Source projects used include [Device](https://github.com/kudit/Device) v\(Device.version), [ParticleEffects](https://github.com/kudit/ParticleEffects) v\(ParticleEffects.version), and [Ink](https://github.com/JohnSundell/Ink).\(connect.additionalLegalInfo)")
                .font(.footnote)
        }
        .refreshable {
            await KuditConnect.shared.loadFromServer()
        }
        .navigationTitle("Help & FAQs")
        .toolbar {
            Button("Done") {
                dismiss()
            }
        }
        .navigationWrapper() // TODO: Set default size of sheet on macOS
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

#endif
