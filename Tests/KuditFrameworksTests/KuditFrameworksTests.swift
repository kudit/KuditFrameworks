#if canImport(XCTest)
import XCTest
@testable import KuditFrameworks

final class KuditFrameworksTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KuditFrameworks().text, "Hello, World!")
    }
    func testSleep() throws {
        let then = time()
        await sleep(5)
        let now = time()
        
        XCTAssertEqual(now - then, 5)
    }
}
#endif
