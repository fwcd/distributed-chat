import Foundation

public protocol ChatProtocolMessageStorage {
    var size: Int { get set }

    func store(message: ChatProtocol.Message)

    @discardableResult
    func deleteMessage(id: UUID) -> Bool

    func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)?) -> [ChatProtocol.Message]
}
