import Foundation

public protocol ChatMessageStorage {
    public init(storageSize: Int)

    public func storeMessage(message: ChatProtocol.Message)

    public func deleteMessage(id: UUID) -> Bool?

    public func setStorageSize(size: Int)

    public func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)) -> [ChatProtocol.Message]
}