import Foundation

public struct ChatMessage: Identifiable, Codable {
    public let id: UUID
    public var timestamp: Date
    public var author: ChatUser
    public var content: String
    public var channelName: String?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        author: ChatUser,
        content: String,
        channelName: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
        self.channelName = channelName
    }
}
