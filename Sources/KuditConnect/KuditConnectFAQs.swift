#if canImport(SwiftUI)
import SwiftUI

struct KuditConnectFAQ: View {
    @Environment(\.colorScheme) var colorScheme
    var faq: KuditFAQ
    var body: some View {
        let html = faq.answerHTML(textColor: colorScheme == .dark ? .white : .black)
#if canImport(WebKit) && !os(watchOS) && !os(tvOS)
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

import MotionEffects // for version string
import Device

// TODO: Add searching and pull to refresh to FAQs
struct KuditConnectFAQs: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    var selectedFAQ: String? // TODO: allow setting this to automatically navigate to the selected FAQ
    @ObservedObject var connect: KuditConnect
    var body: some View {
        NavigationView {
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
                Section("Question not answered?") {
                    Button("Contact Support") {
                        KuditConnect.shared.contactSupport(openURL)
                    }
                }
                // TODO: add in section to contact support
                Text("\(Application.main.name) v\(Application.main.version) © \(String(Date().year)) Kudit LLC All Rights Reserved.\nRead our [Privacy Policy](https://kudit.com/privacy.php) or [Terms of Use](https://kudit.com/terms.php).\n\nOpen Source projects used include [Device](https://github.com/kudit/Device) v\(Device.version), [MotionEffects](https://github.com/kudit/MotionEffects) v\(MotionEffects.version), and [Ink](https://github.com/JohnSundell/Ink).\(connect.additionalLegalInfo)")
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

#endif
