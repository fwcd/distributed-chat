import Foundation

public struct ChatMessage: Codable {
    public var timestamp: Date = Date()
    public var author: ChatUser
    public var content: ChatMessageContent
    public var channelName: String?
    
    public init(
        timestamp: Date = Date(),
        author: ChatUser,
        content: ChatMessageContent,
        channelName: String? = nil
    ) {
        self.timestamp = timestamp
        self.author = author
        self.content = content
        self.channelName = channelName
    }
}
