#if canImport(XCTest)
import XCTest
@testable import KuditFrameworks

extension Testable {
	static func runTests() async throws {
		for test in Self.tests {
			let (result, debugString) = try await test.task()
			XCTAssert(result, debugString)
			print(test)
		}
	}
}

final class KuditFrameworksTests: XCTestCase {
	func testCharacterSet() async throws {
		try await CharacterSet.runTests()
	}

	func testString() async throws {
		try await String.runTests()
	}
	
	func testPHP() async throws {
		try await PHP.runTests()
	}
	
	func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KuditFrameworks().text, "Hello, World!")
    }
}
#endif
