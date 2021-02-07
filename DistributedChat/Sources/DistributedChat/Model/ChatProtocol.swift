import Foundation

public enum ChatProtocol {
    public struct MessageRequest: Hashable, Codable {
        /// The newest timestamp from a received message for a specific author
        public var vectorTime: [UUID: Date] = [:]
    }

    public struct Message: Identifiable, Codable {
        public var id: UUID                 // unique for EVERY message with the sole exception of rebroadcasts
        public var timestamp: Date          // the (physical) timestamp
        public var sourceUserId: UUID       // the possibly indirect source user
        public var destinationUserId: UUID? // the possibly indirect recipient user, if there is any
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var deletedChatMessages: [ChatDeletion]?
        public var messageRequest: MessageRequest?
        public var logicalClock: Int

        public init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            sourceUserId: UUID,
            destinationUserId: UUID? = nil,
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            deletedChatMessages: [ChatDeletion]? = nil,
            messageRequest: MessageRequest? = nil,
            logicalClock: Int
        ) {
            self.id = id
            self.timestamp = timestamp
            self.sourceUserId = sourceUserId
            self.destinationUserId = destinationUserId
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.deletedChatMessages = deletedChatMessages
            self.logicalClock = logicalClock
            self.messageRequest = messageRequest
        }

        /// Whether the given user is the destination.
        public func isDestination(userId: UUID) -> Bool {
            destinationUserId.map { $0 == userId } ?? true
        }
    }
}
