import XCTest
@testable import DistributedChat

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

final class ChatMessageTests: XCTestCase {
    static var allTests = [
        ("testSerialization", testSerialization),
    ]

    func testSerialization() throws {
        let alice = ChatUser(name: "Alice")
        let bob = ChatUser(name: "Bob")

        let message1 = ChatMessage(author: alice, content: "Hi!") // implicitly .right through ExpressibleByStringLiteral
        let message2 = ChatMessage(author: alice, content: .encrypted(.init(sealed: Data([0, 1, 2]), signature: Data([3, 4]), ephemeralPublicKey: Data([5, 6, 7]))))
        let message3 = ChatMessage(author: bob, content: "Test", attachments: [
            ChatAttachment(type: .file, name: "example.html", content: .url(URL(string: "https://example.com")!)),
            ChatAttachment(type: .voiceNote, name: "test.mp3", content: .encrypted(.init(sealed: Data([8, 9, 10]), signature: Data(), ephemeralPublicKey: Data([13]))))
        ])

        try XCTAssertEqual(message1, coded(message1))
        try XCTAssertEqual(message2, coded(message2))
        try XCTAssertEqual(message3, coded(message3))
    }

    private func coded<T>(_ value: T) throws -> T where T: Codable {
        try decoder.decode(T.self, from: encoder.encode(value))
    }
}
