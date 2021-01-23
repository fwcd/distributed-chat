import Foundation

public struct ChatMessage: Codable {
    public var timestamp: Date = Date() // TODO: Specify time zone?
    public var author: ChatUser
    public var content: ChatMessageContent
}
