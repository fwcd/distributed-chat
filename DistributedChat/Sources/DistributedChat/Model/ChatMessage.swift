import Foundation

public struct ChatMessage: Codable {
    public var timestamp: Date = Date()
    public var author: ChatUser
    public var content: ChatMessageContent
    public var channelName: String?
}
