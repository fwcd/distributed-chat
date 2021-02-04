import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var publicKeys: ChatCryptoKeys.Public?
    public var name: String
    public var logicalClock: Int
    
    public var displayName: String { name.isEmpty ? "User \(id.uuidString.prefix(5))" : name }
    
<<<<<<< HEAD
<<<<<<< HEAD
    public init(id: UUID = UUID(), publicKeys: ChatCryptoKeys.Public? = nil, name: String = "") {
=======
    public init(id: UUID = UUID(), name: String = "", vectorClock: Dictionary<UUID,Int> = [:]) {
>>>>>>> 7c13644 (WIP: Implement vector clocks)
=======
    public init(id: UUID = UUID(), name: String = "", logicalClock: Int = 0) {
>>>>>>> 3963adb (WIP: Switch to logical clocks)
        self.id = id
        self.publicKeys = publicKeys
        self.name = name
        self.logicalClock = logicalClock
    }

    // Users are only combined by id

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
