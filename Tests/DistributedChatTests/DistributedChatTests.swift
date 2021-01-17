import XCTest
@testable import DistributedChat

final class DistributedChatTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DistributedChat().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
