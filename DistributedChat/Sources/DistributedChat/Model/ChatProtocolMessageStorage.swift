import Foundation

public protocol ChatProtocolMessageStorage {
    init(storageSize: Int)

    func storeMessage(message: ChatProtocol.Message)

    @discardableResult
    func deleteMessage(id: UUID) -> Bool

    func setStorageSize(size: Int)

    func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)?) -> [ChatProtocol.Message]
}
