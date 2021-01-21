@testable import DistributedChatSimulationServer
import XCTVapor

final class DistributedChatSimulationServerTests: XCTestCase {
    static var allTests = [
        ("testWebFrontend", testWebFrontend)
    ]
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }

    override func tearDown() {
        app.shutdown()
    }

    func testWebFrontend() throws {
        try app.test(.GET, "/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssert(res.body.string.contains("<h1>Distributed Chat Simulation Server</h1>"))
        })
    }
}
