import XCTest
@testable import Puff

final class PuffTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Puff().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
