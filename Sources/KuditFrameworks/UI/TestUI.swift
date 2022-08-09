import SwiftUI

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
