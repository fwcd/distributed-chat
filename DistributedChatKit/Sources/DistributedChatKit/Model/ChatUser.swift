import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var publicKeys: ChatCryptoKeys.Public?
    public var name: String
    public var logicalClock: Int
    
    public var displayName: String { name.isEmpty ? "User \(id.uuidString.prefix(5))" : name }
    
    public init(id: UUID = UUID(), publicKeys: ChatCryptoKeys.Public? = nil, name: String = "", logicalClock: Int = 0) {
        self.id = id
        self.publicKeys = publicKeys
        self.name = name
        self.logicalClock = logicalClock
    }

    // Users are only combined by id and name

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}
