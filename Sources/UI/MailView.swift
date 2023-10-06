//
//  MailView.swift
//  Shout It
//
//  Created by Ben Ku on 10/4/23.
//

import Foundation
// Currently this struct is only thing used here for Kudit Connect
public struct ComposeMailData {
	public let subject: String
	public let recipients: [String]?
	public let message: String
	public let attachments: [AttachmentData]?
	public var mailtoLink: URL {
		return URL(string: "mailto:\(recipients?.joined(separator: ",") ?? "EMAIL@NOT.SPECIFIED")?subject=\(subject.urlEncoded)&body=\(message.urlEncoded)") ?? URL(string: "https://www.apple.com")! // TODO: Encode Attachments
	}
}

public struct AttachmentData {
	public let data: Data
	public let mimeType: String
	public let fileName: String
}

// TODO: Fix and re-work this!!!

/*
import SwiftUI
import UIKit
import MessageUI

typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

public struct MailView: UIViewControllerRepresentable {
	@Environment(\.presentationMode) var presentation
	@Binding var data: ComposeMailData
	let callback: MailViewCallback

	public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		@Binding var presentation: PresentationMode
		@Binding var data: ComposeMailData
		let callback: MailViewCallback
		
		init(presentation: Binding<PresentationMode>,
			 data: Binding<ComposeMailData>,
			 callback: MailViewCallback) {
			_presentation = presentation
			_data = data
			self.callback = callback
		}
		
		public func mailComposeController(_ controller: MFMailComposeViewController,
								   didFinishWith result: MFMailComposeResult,
								   error: Error?) {
			if let error = error {
				callback?(.failure(error))
			} else {
				callback?(.success(result))
			}
			$presentation.wrappedValue.dismiss()
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(presentation: presentation, data: $data, callback: callback)
	}

	public func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
		let vc = MFMailComposeViewController()
		vc.mailComposeDelegate = context.coordinator
		vc.setSubject(data.subject)
		vc.setToRecipients(data.recipients)
		vc.setMessageBody(data.message, isHTML: false)
		data.attachments?.forEach {
			vc.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.fileName)
		}
		vc.accessibilityElementDidLoseFocus()
		return vc
	}

	public func updateUIViewController(_ uiViewController: MFMailComposeViewController,
								context: UIViewControllerRepresentableContext<MailView>) {
	}

	static var canSendMail: Bool {
		MFMailComposeViewController.canSendMail()
	}
}

struct MailViewTest: View {
	@State private var mailData = ComposeMailData(
		subject: "A subject",
		recipients: ["i.love@swiftuirecipes.com"],
		message: "Here's a message",
		attachments: [AttachmentData(
			data: "Some text".data(using: .utf8)!,
			mimeType: "text/plain",
			fileName: "text.txt")
		])
	@State private var showMailView = false
	
	var body: some View {
		Button(action: {
			showMailView.toggle()
		}) {
			Text("Send mail")
		}
		.disabled(!MailView.canSendMail)
		.sheet(isPresented: $showMailView) {
			MailView(data: $mailData) { result in
				print(result)
			}
		}
	}
}

struct MailViewTest_Previews: PreviewProvider {
	static var previews: some View {
		MailViewTest()
	}
}
//#Preview("Mail View Test") {
//	MailViewTest()
//}
*/
