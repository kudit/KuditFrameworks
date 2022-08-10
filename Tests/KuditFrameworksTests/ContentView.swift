import SwiftUI
import KuditFrameworks

public struct ContentView: View {
    
    public init() {}
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var time = -1
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, Kudit world!")
            Text("Unix time: \(time)").onReceive(timer, perform: { _ in
                //debug("updating \(time)")
                time = PHP.time()
            })
        }
    }
}
