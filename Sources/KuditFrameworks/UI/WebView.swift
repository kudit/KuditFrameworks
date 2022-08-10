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
    
    public init(webView: WKWebView, delegate: WebViewDelegate) {
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
#if canImport(UIKit)
typealias ViewRepresentable = UIViewRepresentable
public struct WebView: ViewRepresentable {
    public var url: URL
    public var delegate: WebViewDelegate? = nil
    public var localDelegate: WebViewDelegateManager? = nil
    
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
