@testable import DistributedChatSimulationServer
import XCTVapor

final class DistributedChatSimulationServerTests: XCTestCase {
    static var allTests = [
        ("testWebFrontend", testWebFrontend)
    ]

    func testWebFrontend() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssert(res.body.string.contains("<h1>Distributed Chat Simulation Server</h1>"))
        })
    }
}
