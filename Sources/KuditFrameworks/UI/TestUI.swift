import SwiftUI

// MARK: - Test UI
public struct TestRow: View {
    @ObservedObject public var test: Test
    
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
    public var body: some View {
        List {
            Text("Tests:")
            ForEach(tests, id: \.title) { item in
                if #available(iOS 15.0, *) {
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

struct Tests_Previews: PreviewProvider {
    static var previews: some View {
        TestsListView(tests: PHP.tests + String.tests)
    }
}
