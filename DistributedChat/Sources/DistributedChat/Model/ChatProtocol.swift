import Foundation

public enum ChatProtocol {
    public struct Message: Identifiable, Codable {
        public var id: UUID
        public var addedChatMessages: [ChatMessage]?
        public var updatedPresences: [ChatPresence]?
        public var chatMessageRequest: chatMessageRequest?

        // TODO: Logical clock for eventual consistency
        // (e.g. Lamport timestamp or vector clock)

        // TODO: Removed messages, status updates, etc.?

        public init(
            id: UUID = UUID(),
            addedChatMessages: [ChatMessage]? = nil,
            updatedPresences: [ChatPresence]? = nil,
            chatMessageRequest: chatMessageRequest? = nil
        ) {
            self.id = id
            self.addedChatMessages = addedChatMessages
            self.updatedPresences = updatedPresences
            self.chatMessageRequest = chatMessageRequest
        }
    }
}
