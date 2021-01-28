import Foundation

public struct ChatPresence: Identifiable, Codable, Hashable {
    public var user: ChatUser
    public var status: ChatStatus
    public var info: String?
    
    public var id: UUID { user.id }
    
    public init(user: ChatUser = ChatUser(), status: ChatStatus = .online, info: String? = nil) {
        self.user = user
        self.status = status
        self.info = info
    }
}
