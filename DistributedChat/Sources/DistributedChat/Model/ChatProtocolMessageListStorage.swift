import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatProtocolMessageListStorage")

public struct ChatProtocolMessageListStorage: ChatProtocolMessageStorage {
    // TODO: Perhaps use a more efficient data structure, e.g.
    //       a cyclic buffer to make cropping efficient or
    //       a priority queue to make insertion efficient?
    private var list: [ChatProtocol.Message]
    public var size: Int {
        didSet {
            if size < 0 { fatalError("Storage size cannot be less than zero!") }
            crop()
        }
    }

    public init(size: Int) {
        self.list = [ChatProtocol.Message]()
        self.size = size
    }

    public mutating func store(message: ChatProtocol.Message) {
        // Add new item via insertion sort
        if list.isEmpty {
            list.append(message)
        } else if !contains(id: message.id) {
            for (index, value) in list.enumerated() {
                if value.logicalClock <= message.logicalClock && (index == list.count - 1 || list[index + 1].logicalClock > message.logicalClock) {
                    list.insert(message, at: index)
                }
            }

            crop()
            log.debug("Stored chat messages: \(list.flatMap { $0.addedChatMessages ?? [] }.map(\.displayContent))")
        }
    }

    @discardableResult
    public mutating func deleteMessage(id: UUID) -> Bool {
        for (index, value) in list.enumerated() {
            if value.id == id {
                list.remove(at: index)
                return true
            }
        }
        return false
    }

    public func getStoredMessages(required: ((ChatProtocol.Message) -> Bool)?)  -> [ChatProtocol.Message] { 
        guard let required = required else { return list }

        var returnValue: [ChatProtocol.Message] = [ChatProtocol.Message]()
        for item in list {
            if required(item) {
                returnValue.append(item)
            }
        }
        return returnValue
    }

    private func contains(id: UUID) -> Bool {
        for item in list {
            if item.id == id {
                return true
            }
        }
        return false
    }

    private mutating func crop() {
        // Remove logically oldest items until list is small enough
        let delta = list.count - size
        if delta > 0 {
            list.removeFirst(delta)
        }
    }
}
