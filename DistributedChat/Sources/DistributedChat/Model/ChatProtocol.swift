import Foundation

public enum ChatProtocol {
<<<<<<< HEAD
    public struct Message: Identifiable, Codable {
        public var id: UUID
=======
    public struct Message: Codable {
        public var visitedUsers: Set<UUID>
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 181be05 (Forward to messages. TODO: Circular routes)
=======
>>>>>>> ad98de9 (WIP: Switch to logical clocks)
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var logicalClock: Int

        // TODO: Logical clock for eventual consistency
        // (e.g. Lamport timestamp or vector clock)

        // TODO: Removed messages, status updates, etc.?

        public init(
<<<<<<< HEAD
            id: UUID = UUID(),
=======
            visitedUsers: Set<UUID> = [],
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 181be05 (Forward to messages. TODO: Circular routes)
=======
>>>>>>> ad98de9 (WIP: Switch to logical clocks)
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            logicalClock: Int? = nil
        ) {
            self.id = id
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.logicalClock = logicalClock
        } 
    }
}
