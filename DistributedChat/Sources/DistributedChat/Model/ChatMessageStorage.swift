import Foundation

public protocol ChatMessageStorage {
    init(storageSize: Int)

    func storeMessage(message: ChatProtocol.Message)

    func deleteMessage(id: UUID) -> Bool?

    func setStorageSize(size: Int)

    func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)?) -> [ChatProtocol.Message]
}