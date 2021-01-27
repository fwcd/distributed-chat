import Foundation

public enum ChatProtocol {
<<<<<<< HEAD
    public struct Message: Identifiable, Codable {
        public var id: UUID
=======
    public struct Message: Codable {
        public var visitedUsers: Set<UUID>
<<<<<<< HEAD
>>>>>>> 181be05 (Forward to messages. TODO: Circular routes)
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
=======
        public var addedChatMessages: [ChatMessage]
        public var vectorClock: Dictionary<UUID, Int>
>>>>>>> de6b84a (Forward to messages. TODO: Circular routes)

        // TODO: Logical clock for eventual consistency
        // (e.g. Lamport timestamp or vector clock)

        // TODO: Removed messages, status updates, etc.?

        public init(
<<<<<<< HEAD
            id: UUID = UUID(),
=======
            visitedUsers: Set<UUID> = [],
<<<<<<< HEAD
>>>>>>> 181be05 (Forward to messages. TODO: Circular routes)
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil
        ) {
            self.id = id
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
=======
            addedChatMessages: [ChatMessage] = [],
            vectorClock: Dictionary<UUID, Int> = [:]
        ) {
            self.visitedUsers = visitedUsers
            self.addedChatMessages = addedChatMessages
            self.vectorClock = vectorClock
>>>>>>> de6b84a (Forward to messages. TODO: Circular routes)
        }
    }
}
