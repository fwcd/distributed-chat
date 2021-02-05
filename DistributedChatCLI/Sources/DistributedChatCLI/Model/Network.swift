import DistributedChat
import Foundation

class Network {
    private(set) var presences: [UUID: ChatPresence] = [:]

    @discardableResult
    func register(presence: ChatPresence) -> Bool {
        let id = presence.user.id
        let hasChanged = presences[id] != presence
        presences[id] = presence
        return hasChanged
    }
}
