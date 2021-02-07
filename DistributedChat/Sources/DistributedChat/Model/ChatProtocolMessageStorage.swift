import Foundation

public protocol ChatProtocolMessageStorage {
    var size: Int { get set }

    mutating func store(message: ChatProtocol.Message)

    @discardableResult
    mutating func deleteMessage(id: UUID) -> Bool

    mutating func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)?) -> [ChatProtocol.Message]
}
