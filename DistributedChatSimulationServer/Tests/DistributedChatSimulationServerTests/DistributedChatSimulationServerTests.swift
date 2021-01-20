@testable import DistributedChatSimulationServer
import XCTVapor

final class DistributedChatSimulationServerTests: XCTestCase {
    static var allTests = [
        ("testHelloWorld", testHelloWorld)
    ]

    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
}
