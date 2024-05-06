#if canImport(SwiftUI)
import SwiftUI

// MARK: - Test UI
public struct TestRow: View {
    @ObservedObject public var test: Test
    
    // only necessary since in module and otherwise inaccessible outside package
    public init(test: Test) {
        self.test = test
    }
    
    public var body: some View {
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

public struct TestsListView: View {
    public var tests: [Test]
    
    // only necessary since in module and otherwise inaccessible outside package
    public init(tests: [Test]) {
        self.tests = tests
    }
    
    public var body: some View {
        List {
            Text("Tests:")
            ForEach(tests, id: \.title) { item in
                if #available(iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                    TestRow(test: item)
                        .task {
                            item.run()
                        }
                } else {
                    // Fallback on earlier versions
                    TestRow(test: item)
                        .onAppear {
                            item.run()
                        }
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

#Preview("Tests") {
    TestsListView(tests: CharacterSet.tests + String.tests + PHP.tests)
}

/// For KuditConnect for testing
public extension View {
    func testBackground() -> some View {
        ZStack {
            Color.clear
            self
        }
        .background(.conicGradient(colors: .rainbow, center: .center))
        .ignoresSafeArea()
    }
}
#endif
