// MARK: - Full Screen Fade Cover

#if canImport(SwiftUI)
import SwiftUI

//@available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *)
struct FullScreenFadeCoverModifier<ViewContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    /// for dismissing view since fade dismissal happens before isPresented is removed.
    @Binding var isVisible: Bool
    var onDismiss: (() -> Void)? = nil
    var content: () -> ViewContent
    
    var visibilityHack: Bool {
        .isOS(.watchOS)
    }
    
    var overlayContent: some View {
        Group {
            // fade in with animation (`.onAppear` doesn't seem to work on watchOS
            if isVisible || visibilityHack {
                content()
                    .onDisappear {
                        print("On Disappear called")
                        // dismiss the FullScreenCover
                        isPresented = false
                    }
            }
        }
        // onChange needs to happen before onAppear or it won't work for some reason...
        .backport.onChange(of: isVisible) {
//            print("Visible changed to \(isVisible)")
            if visibilityHack {
                if !isVisible {
                    isPresented = false
                }
            }
        }
        .onAppear { // fade in and then show content
//            print("Overlay content appeared")
            isVisible = true
        }
    }
    
    func body(content wrapperContent: Content) -> some View {
        Group {
#if os(macOS) && !targetEnvironment(macCatalyst)
            // .fullScreenCover is not supported on macOS so just open a new window
            GeometryReader { proxy in
                wrapperContent.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                    overlayContent
                    // make same size as the calling window
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    
                }
            }
#else
            wrapperContent
                .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
                    overlayContent
                        .closure { view in
                            if #available(iOS 16.4, macOS 13.3, macCatalyst 16.4, tvOS 16.4, watchOS 9.4, *) {
                                AnyView(view.presentationBackground(.clear))
                            } else {
                                AnyView(view)
                            }
                        }
                }
#endif
        }
        .transaction({ transaction in
            //            print("Transaction triggered")
            // disable the default FullScreenCover animation
            transaction.disablesAnimations = true
            
            // add custom animation for presenting and dismissing the FullScreenCover
            transaction.animation = .linear(duration: 0.2)
        })
    }
}

public extension View {
    /// Fades in a full screen view rather than sliding up.  Does require modifying a different value for dismissing which must be included and used to dismiss.
    func fullScreenFadeCover(
        isPresented: Binding<Bool>,
        isVisible: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        self.modifier(FullScreenFadeCoverModifier(isPresented: isPresented, isVisible: isVisible, onDismiss: onDismiss, content: content))
    }
}

//@available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *)
struct TestView: View {
    @State var presented = false
    @State var visible = false
    var body: some View {
        Button("Show Full Screen") {
            presented = true
        }
        .testBackground()
        .padding()
        .background(.quaternary, in: Capsule())
        .fullScreenFadeCover(isPresented: $presented, isVisible: $visible, onDismiss: {
            print("Full Screen Dismissed")
        }) {
            ZStack {
                Color.clear
                VStack {
                    Text("Full screen view.  Lots of text can go here.")
                    if !.isOS(.watchOS) {
                        Button("Dismiss") {
                            visible = false
                        }
                    }
                }
                .padding()
                .backgroundMaterial()
                .padding()
            }
            .background(.red.opacity(0.4))
            //            .presentationBackground(.clear)
        }
    }
}

#Preview("FullScreenFadeCover") {
    TestView()
}
#endif
