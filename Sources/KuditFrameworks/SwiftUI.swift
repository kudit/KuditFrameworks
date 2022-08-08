//
//  File.swift
//  
//
//  Created by Ben Ku on 8/8/22.
//

import Foundation
import SwiftUI
import WebKit

// MARK: Web View for SwiftUI
public protocol WebViewDelegate {
	func save(manager: WebViewDelegateManager)
	func pageFinishedLoading(webView: WKWebView, contents: String)
}
public class WebViewDelegateManager: NSObject, WKNavigationDelegate {
	var webView: WKWebView
	var delegate: WebViewDelegate
	
	init(webView: WKWebView, delegate: WebViewDelegate) {
		self.webView = webView
		self.delegate = delegate
		super.init()
		webView.navigationDelegate = self
	}
	
	public func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
								   completionHandler: { (html: Any?, error: Error?) in
			if let error = error {
				debug("WEBVIEW ERROR: \(error)")
				return
			}
			guard let html = html as? String else {
				debug("WEBVIEW HTML UNKNOWN: \(String(describing:html))")
				return
			}
			//debug("WEBVIEW LOADED: \(html)")
			self.delegate.pageFinishedLoading(webView: webView, contents: html)
		})
	}
}
#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
public struct WebView: ViewRepresentable {
	var url: URL
	var delegate: WebViewDelegate? = nil
	var localDelegate: WebViewDelegateManager? = nil
	
	public func makeUIView(context: Context) -> WKWebView {
		let webView = WKWebView()
		if let delegate = delegate {
			delegate.save(manager: WebViewDelegateManager(webView: webView, delegate: delegate))
		}
		return webView
	}
	
	public func updateUIView(_ webView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
}
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#endif

// MARK: - Test UI
struct TestRow: View {
	@ObservedObject var test: Test
	
	var body: some View {
		HStack(alignment: .top) {
			Text(test.progress.description)
			Text(test.title)
			Spacer()
			Button("▶️") {
				test.run()
			}
		}
		if let errorMessage = test.errorMessage {
			Text(errorMessage)
		}
	}
}

struct TestsListView: View {
	var tests: [Test]
	var body: some View {
		List {
			Text("Tests:")
			ForEach(tests, id: \.title) { item in
				TestRow(test: item)
					.task {
						item.run()
					}
			}
		}
	}
}
/* don't need separate preview view for row
 struct TestRow_Previews: PreviewProvider {
 static var previews: some View {
 TestRow(test: PHP.tests[0])
 }
 }*/

struct Tests_Previews: PreviewProvider {
	static var previews: some View {
		TestsListView(tests: PHP.tests + String.tests)
	}
}
