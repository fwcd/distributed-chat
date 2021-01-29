import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var publicKeys: ChatCryptoKeys.Public?
    public var name: String
    public var vectorClock: Dictionary<UUID,Int>
    
    public var displayName: String { name.isEmpty ? "User \(id.uuidString.prefix(5))" : name }
    
<<<<<<< HEAD
    public init(id: UUID = UUID(), publicKeys: ChatCryptoKeys.Public? = nil, name: String = "") {
=======
    public init(id: UUID = UUID(), name: String = "", vectorClock: Dictionary<UUID,Int> = [:]) {
>>>>>>> 7c13644 (WIP: Implement vector clocks)
        self.id = id
        self.publicKeys = publicKeys
        self.name = name
        self.vectorClock = vectorClock
        self.vectorClock[self.id] = 0
    }

    // Users are only combined by id

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
