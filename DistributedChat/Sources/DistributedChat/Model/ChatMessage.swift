import Foundation

public struct ChatMessage: Identifiable, Hashable, Codable {
    public let id: UUID
    public var timestamp: Date // TODO: Specify time zone?
    public var author: ChatUser
    public var content: String
    public var channelName: String?
    public var repliedToMessageId: UUID?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        author: ChatUser,
        content: String,
        channelName: String? = nil,
        repliedToMessageId: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
        self.channelName = channelName
        self.repliedToMessageId = repliedToMessageId
    }
}
