import Foundation

public enum ChatProtocol {
    public struct Message: Identifiable, Codable {
        public var id: UUID
        public var sourceUserId: UUID
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var deleteMessages: [ChatDeletion]?
        public var chatMessageRequest: ChatMessageRequest?
        public var logicalClock: Int

        // TODO: Removed messages, status updates, etc.?

        public init(
            id: UUID = UUID(),
            sourceUserId: UUID,
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            deleteMessages: [ChatDeletion]? = nil,
            logicalClock: Int,
            chatMessageRequest: ChatMessageRequest? = nil
        ) {
            self.id = id
            self.sourceUserId = sourceUserId
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.deleteMessages = deleteMessages
            self.logicalClock = logicalClock
            self.chatMessageRequest = chatMessageRequest
        }
    }
}
