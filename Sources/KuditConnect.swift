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

public struct KuditConnectMenu: View {
	public var customizeMessageBody: (String) -> String // TODO: Add ability to add files and photos?
	
	public init(customizeMessageBody: @escaping (String) -> String = {$0}) {
		self.customizeMessageBody = customizeMessageBody
	}
	
	@State var supportEmailData = ComposeMailData(subject: "Unspecified", recipients: [], message: "Overwrite", attachments: nil)
	
	@Environment(\.openURL) var openURL

	@State private var showMailView = false
	@State private var kudosMessageText = "Sending your kudos to the team..."
	@State private var showKudos = false
	@State private var isKudosScreenVisible = false
	public var body: some View {
		Menu {
			Text("Version \(Application.main.version)")
			// TODO: Restore FAQ interface
/*			Button(action: {
				Vibration.system.vibrate()
			}) {
				Label("Help & FAQs", systemImage: "questionmark.circle")
			}*/
			Button(action: {
				Vibration.light.vibrate()
				// Generate support email when button pressed but not before
				supportEmailData = ComposeMailData(
					subject: Self.supportEmailSubject,
					recipients: [Self.supportEmail],
					message: generateSupportEmail(),
					attachments: nil)
				let link = supportEmailData.mailtoLink
				debug(link, level: .DEBUG)
				openURL(link)
//				showMailView = true
			}) {
				Label("Contact Support", systemImage: "envelope")
			}
//			.disabled(!MailView.canSendMail)
//			.sheet(isPresented: $showMailView) {
//				MailView(data: $supportEmailData) {_ in
//					print("MailViewCallback")
//				}
//			}
/*			Button(action: {
				Vibration.medium.vibrate()
			}) {
 // Button-triggered reviews are not allowed by App Store
				Label("Leave a Review", systemImage: "star")
			}*/
/*			Button(action: {
				Vibration.heavy.vibrate()
			}) {
				Label("Share App With Friends", systemImage: "square.and.arrow.up")
			}*/
			Button(action: {
				Vibration.light.vibrate()
				showKudos.toggle()
				Task {
					// Use kudos messages result in KudosView - have a binding so can change/update
					kudosMessageText = await sendKudos()
					Vibration.heavy.vibrate()
				}
			}) {
				Label("Send Us Kudos", systemImage: "hands.sparkles") // hand.thumbsup
			}
//			Text("KuditFrameworks v\(Application.main.frameworkVersion)")
			Text("KuditConnect v\(Self.kuditConnectVersion)")
			//					Button("Add Passbook Pass", action: {})
		} label: {
			Label("KuditConnect support menu", systemImage: "questionmark.bubble")
			// TODO: Try with KuditLogo shape?
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

	// MARK: - Support Email
	public static var supportEmail = "support+\(Application.main.appIdentifier)@kudit.com"
	public static var supportEmailSubject = "App Feedback for \(Application.main.name)"
	public var appInformation: String {
		"""
  Application: \(Application.main.name)
  Version: \(Application.main.version)
  Previously run versions: \(Application.main.versionsRun.joined(separator: ", "))
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

	// MARK: - Kudos
	private static let kuditAPIURL = "https://www.kudit.com/api"
	private static let kuditConnectVersion = "3.0"
	
	// https://www.kudit.com/api/kudos.php?identifier=com.kudit.BROWSERTEST&version=1.2.3&kcVersion=3.2.1
	// Returns "SUCCESS"
	
	/// Send Kudos to server for this app
	public func sendKudos() async -> String {
		let identifier = Application.main.appIdentifier
		let version = Application.main.version
		let kudosAPI = "\(Self.kuditAPIURL)/kudos.php?identifier=\(identifier.urlEncoded)&version=\(version.urlEncoded)&info=\(customizeMessageBody(appInformation).urlEncoded)"
		debug("Kudit Connect: Kudos URL: \(kudosAPI)", level: .NOTICE)
		let displayName = Application.main.name
		
		let problemText = "There was a problem sending your kudos to the \(displayName) team!"

		guard let url = URL(string:kudosAPI) else {
			return "PROGRAMMING ERROR:  Could not generate URL from: \(kudosAPI)"
		}
		let urlRequest = URLRequest(url: url)
		// run this block code on a background thread
		do {
			let (data, response) = try await URLSession.shared.data(for: urlRequest)
			
			guard (response as? HTTPURLResponse)?.statusCode == 200 else {
				return "\(problemText)  The server may be offline.  Please try again later.\nError code \(response):\(String(describing: data))"
			}
			guard let results = String(data: data, encoding: .utf8) else {
				return "\(problemText)  The server said: \(String(describing: data))"
			}
			guard results == "SUCCESS" else {
				return "\(problemText)  We tried to send your kudos to the team but the server said \(String(describing: results)).  Please take a screenshot and email us or try again later."
			}
			return "Thank you so much for sending kudos to the \(displayName) team!  It means a lot to them.  Please rate the app and leave a review to really help the team out!"
		} catch {
			return "\(problemText)  Make sure you're connected to the internet. \(String(describing: error))"
		}
	}
}
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
	var body: some View {
		NavigationView {
			List(1..<100, id: \.self) { index in
				Text("Row \(index)")
			}
			.toolbar {
				
				// Add the menu button
				KuditConnectMenu()

			}
		}

	}
}

private struct KCTestView_Previews: PreviewProvider {
	static var previews: some View {
		KudosView(messageText: .constant("Hello world \(Application.main.name) test message text"), isKudosScreenVisible: .constant(true))
		KCTestView()
	}
}
//#Preview("Kudos View") {
//	if #available(iOS 16.4, *) {
//		KudosView(isKudosScreenVisible: .constant(true))
//	} else {
//		// Fallback on earlier versions
//		Text("KuditConnect Unavailable")
//	}
//}
//
//// MARK: - Preview
//#Preview("KuditConnect") {
//	KCTestView()
//}
