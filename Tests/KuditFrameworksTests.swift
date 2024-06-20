#if canImport(Testing) && canImport(KuditFrameworks)
@testable import KuditFrameworks
import Testing

extension Testable {
    @MainActor
    static func runTests() async throws {
        for test in Self.tests {
            let (result, debugString) = try await test.task()
            #expect(result, .init(stringLiteral: debugString)) // TODO: Include line number of original test call!
            print(test)
        }
    }
}

@Suite
struct KuditFrameworksTests {
    @Test
    func testCharacterSet() async throws {
        try await CharacterSet.runTests()
    }

    @Test
    func testString() async throws {
        try await String.runTests()
    }

    @Test
    func testDate() async throws {
        try await Date.runTests()
    }

    @Test
    func testVersion() async throws {
        try await Version.runTests()
    }

    @Test
    func testPHP() async throws {
        try await PHP.runTests()
    }
}
#endif
