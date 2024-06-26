import Foundation

// TODO: Retool as macros for easier test writing and allow tests to fail inline where the code fails.
public typealias TestTuple = (Bool, String)
public typealias TestClosure = () async throws -> TestTuple

// don't make this public to avoid compiling test stuff into framework, however, do make public so apps can add in their own tests.
public protocol Testable {
    @MainActor static var tests: [Test] { get }
}

// Test Handlers
@MainActor
public final class Test: ObservableObject {
    public enum TestProgress: CustomStringConvertible, Sendable {
        case notStarted
        case running
        case pass
        case fail
        public var description: String {
            switch self {
            case .notStarted:
                return "❇️"
            case .running:
                return "🔄"
            case .pass:
                return "✅"
            case .fail:
                return "⛔"
            }
        }
    }
    public let title: String
    public var task: TestClosure
    @Published public var progress: TestProgress = .notStarted
    @Published public var errorMessage: String? = nil
    
    public init(_ title: String, _ task: @escaping TestClosure ) {
        self.title = title
        self.task = task
    }
    
    public func run() {
        self.progress = .running
        // make sure to run the "work" in a separate thread since we don't want any of this running on the main thread and potentially bogging things down
        Task {
            do {
                //await PHP.sleep(2)
                let (result, debugString) = try await task()
                main {
                    self.progress = result ? .pass : .fail
                }
                if !result {
                    print("•\(title) Failed:\n\(debugString)")
                }
                //debug("Complete \(self)")
            } catch {
                errorMessage = "Error: \(error)"
                main {
                    self.progress = .fail
                }
                print("•\(title) Errored:\n\(self)")
            }
        }
    }
    
    public var description: String {
        let errorString = (errorMessage != nil ? "\n\t\(errorMessage!)" : "")
        return "\(progress): \(title)\(errorString)"
    }
}
public extension Test {
    static func dummyAsyncThrows() async throws {
    }
}

#if canImport(SwiftUI)
import SwiftUI
struct Test_Previews: PreviewProvider {
    static var previews: some View {
        TestsListView(tests: PHP.tests)
    }
}
#endif
