import SwiftUI
import WebKit
// https://alexpaul.dev/2023/01/19/rendering-web-content-in-swiftui-using-uiviewrepresentable-html-and-css/

// 1
// Create a custom `UIViewRepresentable` that will render web content.
struct HTMLView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    // 4
    // Access the `homepage.html` file that is stored in the app bundle
    var fileURL: URL {
        guard let url = Bundle.main.url(forResource: "homepage", withExtension: "html") else {
            fatalError("path does not exist")
        }
        return url
    }
    
    /// Accepts a user HTML string e.g <p>SwiftUI is <b>awesome</b></p>
    var htmlString: String?
    
    func makeUIView(context: Context) -> WKWebView {
        // 5
        // Configure the WKWebView
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        // 6
        // Part of the configuration is to allow for back-and-forth navigation between web pages.
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let htmlString else {
            // 7
            // Load the `homepage.html` page (has CSS styling), refer to `styles.css`
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
            return
        }
        // 8
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
            HTMLView(htmlString: """
<html>
    <head>
<style type="text/css">
body {
    margin-top: 40px;
    background-color: black;
    color: white;
    text-align: center;
    font-size: 1.8em;
    font-family: 'Inter', sans-serif;
}
 
main {
    margin-top: 100px;
}
 
a {
    color: white;
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
                This page is designed using CSS.</a>
            </p>
            <div class="image-container">
                <img src="https://developer.apple.com/assets/elements/icons/swiftui/swiftui-96x96_2x.png" />
            </div>
        </main>
    </body>
</html>
""")
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
    }
}
