import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var publicKeys: ChatCryptoKeys.Public?
    public var name: String
    
    public var displayName: String { name.isEmpty ? "User \(id.uuidString.prefix(5))" : name }
    
    public init(id: UUID = UUID(), publicKeys: ChatCryptoKeys.Public? = nil, name: String = "") {
        self.id = id
        self.publicKeys = publicKeys
        self.name = name
    }

    // Users are only combined by id

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
