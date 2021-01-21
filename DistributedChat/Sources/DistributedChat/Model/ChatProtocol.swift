import Foundation

public enum ChatProtocol {
    public struct Message: Codable {
        public var visitedUsers: Set<UUID>
        public var addedChatMessages: [ChatMessage]

        // TODO: Logical clock for eventual consistency
        // (e.g. Lamport timestamp or vector clock)

        // TODO: Removed messages, status updates, etc.?

        public init(
            visitedUsers: Set<UUID> = [],
            addedChatMessages: [ChatMessage] = []
        ) {
            self.visitedUsers = visitedUsers
            self.addedChatMessages = addedChatMessages
        }
    }
}
