import Foundation

public enum ChatProtocol {
    public struct MessageRequest: Hashable, Codable {
        /// The newest (logical) timestamp from a received message for a specific author
        public var vectorTime: [UUID: Int] = [:]
    }

    public struct Message: Identifiable, Codable {
        public var id: UUID
        public var sourceUserId: UUID     // the possibly indirect source user
        public var recipientUserId: UUID? // the DIRECT recipient user, if there is any
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var deletedChatMessages: [ChatDeletion]?
        public var messageRequest: MessageRequest?
        public var logicalClock: Int

        // TODO: Removed messages, status updates, etc.?

        public init(
            id: UUID = UUID(),
            sourceUserId: UUID,
            recipientUserId: UUID? = nil,
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            deletedChatMessages: [ChatDeletion]? = nil,
            logicalClock: Int,
            messageRequest: MessageRequest? = nil
        ) {
            self.id = id
            self.sourceUserId = sourceUserId
            self.recipientUserId = recipientUserId
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.deletedChatMessages = deletedChatMessages
            self.logicalClock = logicalClock
            self.messageRequest = messageRequest
        }

        /// Whether the given user should receive this protocol message.
        public func isReceived(by userId: UUID) -> Bool {
            recipientUserId.map { $0 == userId } ?? true
        }
    }
}
