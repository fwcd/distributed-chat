import Foundation

public struct ChatMessageContent: Codable {
    public var text: String

    public init(text: String) {
        self.text = text
    }
}
