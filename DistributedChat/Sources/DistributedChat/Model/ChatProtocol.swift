import Foundation

public enum ChatProtocol {
    public struct MessageRequest: Hashable, Codable {
        /// Resembles the newest timestamp from a received message for a specific author
        public var vectorTime: [UUID: Int] = [:]
    }

    public struct Message: Identifiable, Codable {
        public var id: UUID
        public var sourceUserId: UUID
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var deletedChatMessages: [ChatDeletion]?
        public var messageRequest: MessageRequest?
        public var logicalClock: Int

        // TODO: Removed messages, status updates, etc.?

        public init(
            id: UUID = UUID(),
            sourceUserId: UUID,
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            deletedChatMessages: [ChatDeletion]? = nil,
            logicalClock: Int,
            messageRequest: MessageRequest? = nil
        ) {
            self.id = id
            self.sourceUserId = sourceUserId
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.deletedChatMessages = deletedChatMessages
            self.logicalClock = logicalClock
            self.messageRequest = messageRequest
        }
    }
}
