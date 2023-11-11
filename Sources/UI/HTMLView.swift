#if canImport(WebKit) && canImport(UIKit)
import SwiftUI
import WebKit
// https://alexpaul.dev/2023/01/19/rendering-web-content-in-swiftui-using-uiviewrepresentable-html-and-css/

class HTMLViewDelegate: NSObject, ObservableObject, WKNavigationDelegate {
    var handleURL: (URL) -> Void = {_ in }
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
		debug("WebView decision handler for navigation action: \(navigationAction)", level: .DEBUG)
        guard let url = navigationAction.request.url else {
            debug("No request url in navigation action: \(navigationAction)", level: .NOTICE)
            return
        }
        debug("WebView Decision Handler for \(url)", level: .DEBUG)
        // don't actually change views for URL.  This really is only used in KuditConnect FAQ views right now, so perhaps re-work this to be more flexible in the future as a true browser.
        switch navigationAction.navigationType {
        case .linkActivated:
            // TODO: open in safari, or open in app
            handleURL(url)
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
            break
        }
/*
        switch navigationAction.navigationType {
        case .linkActivated:
            // TODO: open in safari, or open in app
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)// It will load that link in same WKWebView
            }
        default:
            break
        }
        
        if let url = navigationAction.request.url {
            print(url.absoluteString) // It will give the selected link URL
            
        }
        decisionHandler(.allow)*/
    }
}

// Create a custom `UIViewRepresentable` that will render web content.
public struct HTMLView: UIViewRepresentable {
	@Environment(\.openURL) var openURL
	static var testHTML = """
<html>
    <head>
<style type="text/css">
body {
    margin-top: 40px;
    background-color: blue;
    color: lime;
    text-align: center;
    font-size: 1.8em;
    font-family: 'Inter', sans-serif;
}
 
main {
    margin-top: 100px;
}
 
a {
    color: red;
    text-decoration: underline;
}
 
.image-container {
    margin-top: 60px;
}
 
.image-container img {
    width: 300px;
}
</style>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
        <title>SwiftUI Homepage</title>
    </head>
    <body>
        <header>
            <h1>
                HTML `UIViewRepresentable` rendered `View`
            </h1>
        </header>
        <main>
            <p>
                Learn more about SwiftUI <a href="https://developer.apple.com/xcode/swiftui/">here.</a>
            </p>
            <p>
                This page is designed using <a href="https://www.kudit.com" target="_blank">CSS (new window)</a>.
            </p>
            <p>
             <a href="shoutit://?message=Foobar">ShoutIt special link</a>
            </p>
            <div class="image-container">
                <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" />
            </div>
        </main>
    </body>
</html>
"""
    public typealias UIViewType = WKWebView
        
    /// Accepts a user HTML string e.g <p>SwiftUI is <b>awesome</b></p>
    public var htmlString: String
    
    @StateObject var delegate = HTMLViewDelegate()
    
    public func makeUIView(context: Context) -> WKWebView {
        // Configure the WKWebView
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear

        delegate.handleURL = {
            url in
            openURL(url)
        }
        webView.navigationDelegate = delegate

        // Part of the configuration is to allow for back-and-forth navigation between web pages.
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // If the user passes an HTML string this page will be rendered
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

struct HTMLView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Regular SwiftUI View")
                .font(.headline)
                .padding(.bottom, 20)
            // 2
            // Embed the custom `UIViewRepresentable` View which has HTML content in your SwiftUI View.
            HTMLView(htmlString: HTMLView.testHTML)
                .frame(height: 500)
            // 3
            // SwiftUI cannot style the rendered `HTMLView`, we have to style the HTML server-side
            // or in this case, use a local CSS file.
                .foregroundColor(.teal)
            Text("Another regular SwiftUI View")
                .font(.subheadline)
                .padding(.top, 20)
        }
        .frame(maxHeight: .infinity)

        HTMLView(htmlString: KuditConnect.shared.faqs[safe: 1]?.answerHTML(textColor: .red) ?? HTMLView.testHTML)
    }
}
#endif
