import Foundation

public enum ChatProtocol {
    public struct Message: Identifiable, Codable {
        public var id: UUID
        public var visitedUsers: Set<UUID>
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var logicalClock: Int

        // TODO: Logical clock for eventual consistency
        // (e.g. Lamport timestamp or vector clock)

        // TODO: Removed messages, status updates, etc.?

        public init(
            id: UUID = UUID(),
            visitedUsers: Set<UUID> = [],
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            logicalClock: Int
        ) {
            self.id = id
            self.visitedUsers = visitedUsers
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.logicalClock = logicalClock
        } 
    }
}
