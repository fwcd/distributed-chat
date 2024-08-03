import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatMessageListCache")

public struct ChatMessageListCache: ChatMessageCache {
    // TODO: Perhaps use a more efficient data structure, e.g.
    //       a cyclic buffer to make cropping efficient or
    //       a priority queue to make insertion efficient?
    private var list: [ChatMessage]
    public var size: Int {
        didSet {
            if size < 0 { fatalError("Cache size cannot be less than zero!") }
            crop()
        }
    }

    public init(size: Int) {
        self.list = [ChatMessage]()
        self.size = size
    }

    public mutating func store(message: ChatMessage) {
        // Add new item via insertion sort
        if list.isEmpty {
            list.append(message)
        } else if !contains(id: message.id) {
            for (index, value) in list.enumerated() {
                if value.timestamp <= message.timestamp && (index == list.count - 1 || list[index + 1].timestamp > message.timestamp) {
                    list.insert(message, at: index)
                }
            }

            crop()
            log.debug("Stored chat messages: \(list.map(\.displayContent))")
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

    public func getStoredMessages(required: ((ChatMessage) -> Bool)?)  -> [ChatMessage] { 
        guard let required = required else { return list }

        var returnValue: [ChatMessage] = [ChatMessage]()
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
