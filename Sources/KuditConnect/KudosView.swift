
// MARK: - Kudos

#if canImport(SwiftUI)
import SwiftUI

#if canImport(MotionEffects)
import MotionEffects
#endif
private struct FancyView: View {
    var body: some View {
#if canImport(MotionEffects)
        let behavior = ParticleBehavior(
            birthRate: .frequent,
            lifetime: .long,
            fadeOut: .none,
            emissionAngle: .top,
            spread: .medium,
            initialVelocity: .medium,
            acceleration: .moonGravity, // up?
            blur: .none
        )
        ZStack {
            Color.black.opacity(0.2) // dim background
            ParticleSystemView(behavior: behavior, string: "😊,👍,☺️,👏,🙌")
        }
#else
        Color.yellow.opacity(0.2)
#endif
    }
}

public struct KudosView: View {
    @Binding public var messageText: String
    @Binding public var isKudosScreenVisible: Bool
        
    public var body: some View {
        ZStack {
            FancyView()
            VStack {
                // This is dynamic so we can change after confirming the kudos were sent.  Set to "Sending kudos..." and then change to this message once sent and have option to show error message which automatically generates a bug report.
                Text(messageText)
                    .italic()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
#if !os(watchOS)
                Button("Okay") {
                    // prompt for review if supported
                    Review.request()
                    // hide view and then dismiss
                    isKudosScreenVisible = false
                }
                .enableReviewRequests()
                .buttonStyle(.bordered)
#endif
            }
            .backgroundMaterial()
            .shadow(radius: 10)
            .padding()
        }
    }
}

#Preview("Kudos Alert View") {
    KudosView(messageText: .constant("Test Message Text Longer text should be supported if there is a longer message."), isKudosScreenVisible: .constant(true))
        .testBackground()
}

//@available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *)
struct KudosTestHarness: View {
    @State var showKudos = false
    @State var kudosVisible = false
    @State var showAlert = false
    @State var showFullScreen = false
    @State var text = "This is the initial message text.  Sending Kudos..."
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear // expand
            VStack {
                Button("Show Kudos Screen") {
                    showKudos = true
                    delay(3) {
                        text = "Thank you for sending Kudos!  The team really appreciates your support!"
                    }
                }
                Button("Show Alert") {
                    showAlert = true
                }
            }
        }
        .buttonStyle(.bordered)
        .padding()
        .background(.conicGradient(colors: .rainbow, center: .center))
        .ignoresSafeArea()
        .fullScreenFadeCover(isPresented: $showKudos, isVisible: $kudosVisible) {
            KudosView(messageText: $text, isKudosScreenVisible: $kudosVisible)
                .background(.black.opacity(0.1))
            //Scale down, show view animation?
        }
        .alert("Test Alert", isPresented: $showAlert) {
            Button(role: .destructive) {
                // Handle the deletion.
            } label: {
                Text("Destructive Test")
            }
            Button("Retry") {
                // Handle the retry action.
            }
        }
    }
}

#Preview("Presenting Kudos") {
    KudosTestHarness()
}

#endif
