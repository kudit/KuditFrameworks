//
//  ReviewButton.swift
//
//
//
//  Created by Ben Ku on 5/4/24.
//

/**
 Reviews required that the environment review hook is available.  So we have a two step process.  Add the view modifier .enableReviewRequests() to the button to enable the hook and then call Review.request() from the action code.
 */

#if canImport(SwiftUI)
import SwiftUI

public extension View {
    func enableReviewRequests() -> some View {
        Group {
#if targetEnvironment(macCatalyst) || os(macOS) || os(iOS) || os(visionOS) // since not supported on tvOS or watchOS
            if #available(iOS 16.0, macOS 13.0, macCatalyst 16.0, visionOS 1.0, *) {
                // add modifier
                modifier(ReviewModifier())
            } else {
                self
            }
#else
            self
#endif
        }
    }
}

public class Review: ObservableObject {
    static var shared = Review()
    
    @Published var shouldRequest = false    
    
    /// Trigger a review request (requires a view to have .enableReviewRequests() modifier).
    public static func request() {
//        print("Review.request() called")
        shared.shouldRequest = true
    }
}

#if targetEnvironment(macCatalyst) || os(macOS) || os(iOS) || os(visionOS) // since not supported on tvOS or watchOS
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, visionOS 1.0, *)
struct ReviewModifier: ViewModifier {
    @ObservedObject var review = Review.shared
    @Environment(\.requestReview) var requestReview
    func body(content: Content) -> some View {
        content
//            .border(.green, width: 2)
            .backport.onChange(of: review.shouldRequest) {
//                print("shouldRequest changed to \(review.shouldRequest)!")
                if review.shouldRequest {
//                    print("REQUESTING Review!")
                    requestReview()
                    review.shouldRequest = false // will trigger again but we only care when changing to true.
                }
            }
    }
}
#endif

#Preview {
    VStack {
        Text("Test Review Button")
        Button("Test") {
            print("Button Pressed")
            Review.request()
            print("post request (Request should have been done (Request State: \(Review.shared.shouldRequest))")
        }.enableReviewRequests()
        .buttonStyle(.bordered)
    }
}
#endif
