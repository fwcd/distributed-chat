import Foundation

public class ChatMessageStorageList: ChatMessageStorage {
    private var size: Int
    private var list: [ChatProtocol.Message]

    public required init(storageSize: Int) {
        self.size = storageSize
        self.list = [ChatProtocol.Message]()
    }

    public func storeMessage(message: ChatProtocol.Message) {
        // Add new item via insertion sort
        if !contains(id: message.id){
            for (index, value) in list.enumerated() {
                if value.logicalClock <= message.logicalClock && (index == list.count()-1 || list[index+1].logicalClock > message.logicalClock) {
                    list.insert(message, at: index)
                }
            }

            crop()
        }
    }

    public func deleteMessage(id: UUID) -> Bool? {
        for (index, value) in list.enumerated() {
            if value.id == id {
                list.remove(at: index)
                return true
            }
        }
        return false
    }

    public func setStorageSize(size: Int) /* throws */ {
        if size <= 0 {
            // TODO: Use appropiate exception
            return        
        }
        self.size = size
        crop()
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

    private func crop () {
        // Remove logically oldes item until list is small enough
        while list.count > size {
            list.remove(at: 0)
        }
    }
}