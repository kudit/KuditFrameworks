//
//  SwiftUIView.swift
//  
//
//  Created by Ben Ku on 5/5/24.
//

#if canImport(SwiftUI)
import SwiftUI


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
    @State private var kudosVisible = false
    public var body: some View {
        Menu {
            additionalMenus()
            Section(Application.DEBUG ? "Kudit Connect DEBUG" : "") {
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
                Button(action: {
                    Vibration.light.vibrate()
                    
                    showKudos = true
                    
                    Task {
                        // Use kudos messages result in KudosView - have a binding so can change/update
                        kudosMessageText = await KuditConnect.shared.sendKudos()
                        Vibration.heavy.vibrate()
                    }
                }) {
                    Label("Send Us Kudos", systemImage: "hands.sparkles") // hand.thumbsup
                }
            }
        } label: {
            label()
        }
        /// Kudos view
        .fullScreenFadeCover(isPresented: $showKudos, isVisible: $kudosVisible) {
            KudosView(messageText: $kudosMessageText, isKudosScreenVisible: $kudosVisible)
        } // have before FAQ sheet or it will inherit transcation clause.
        .sheet(isPresented: $showFAQs) {
            KuditConnectFAQs(connect: KuditConnect.shared)
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
            .previewDisplayName("Help & FAQs")
        KuditConnectFAQ(faq: KuditConnect.shared.faqs.first!)
            .previewDisplayName("FAQ")
        KudosView(messageText: .constant("Hello world \(Application.main.name) test message text"), isKudosScreenVisible: .constant(true))
            .previewDisplayName("Kudos")
    }
}

#endif
