import Foundation

public protocol ChatMessageCache {
    var size: Int { get set }

    mutating func store(message: ChatMessage)

    @discardableResult
    mutating func deleteMessage(id: UUID) -> Bool

    mutating func getStoredMessages(required: ((ChatMessage) -> Bool)?) -> [ChatMessage]
}
