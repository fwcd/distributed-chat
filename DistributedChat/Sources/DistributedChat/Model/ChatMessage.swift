import Foundation

public struct ChatMessage: Identifiable, Hashable, Codable {
    public let id: UUID
    public var timestamp: Date // TODO: Specify time zone?
    public var author: ChatUser
    public var content: String
    public var channel: ChatChannel?
    public var attachments: [ChatAttachment]?
    public var repliedToMessageId: UUID?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        author: ChatUser,
        content: String,
        channel: ChatChannel? = nil,
        attachments: [ChatAttachment]? = nil,
        repliedToMessageId: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
        self.channel = channel
        self.attachments = attachments
        self.repliedToMessageId = repliedToMessageId
    }
    
    /// Checks whether the given user id should receive the message.
    public func isReceived(by userId: UUID) -> Bool {
        switch channel {
        case .dm(let recipientId)?:
            return recipientId == userId || author.id == userId
        default:
            return true
        }
    }
}
