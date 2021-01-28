public struct ChatPresence: Codable, Hashable {
    public var user: ChatUser
    public var status: ChatStatus
    public var info: String?
    
    public init(user: ChatUser, status: ChatStatus = .online, info: String? = nil) {
        self.user = user
        self.status = status
        self.info = info
    }
}
