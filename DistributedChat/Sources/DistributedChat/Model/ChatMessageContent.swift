import Foundation

public struct ChatMessageContent: Codable, CustomStringConvertible {
    public var text: String

    public var description: String { text }

    public init(text: String) {
        self.text = text
    }
}
