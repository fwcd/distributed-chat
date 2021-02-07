import Foundation

public struct ChatProtocolMessageListStorage: ChatProtocolMessageStorage {
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
        if !contains(id: message.id){
            for (index, value) in list.enumerated() {
                if value.logicalClock <= message.logicalClock && (index == list.count - 1 || list[index + 1].logicalClock > message.logicalClock) {
                    list.insert(message, at: index)
                }
            }

            crop()
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
        if required == nil {
            return list
        }

        var returnValue: [ChatProtocol.Message] = [ChatProtocol.Message]()
        for item in list {
            if required!(item) {
                returnValue.append(item)
            }
        }
        return returnValue;
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
        // Remove logically oldest item until list is small enough
        while list.count > size {
            list.remove(at: 0)
        }
    }
}