import Foundation

public struct ChatDeletion: Identifiable, Codable, Hashable {
    public var messageId: UUID
    public var author: ChatUser
    public var id: UUID { messasgeId }


    public init(messageId: UUID, author: ChatUser) {
        self.messageId = messageId
        self.author = author
    }
}