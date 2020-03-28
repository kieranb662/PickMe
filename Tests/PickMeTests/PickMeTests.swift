import XCTest
@testable import PickMe

final class PickMeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PickMe().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
