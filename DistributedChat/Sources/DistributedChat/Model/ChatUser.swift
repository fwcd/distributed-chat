import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String
    
    public var displayName: String { name.isEmpty ? "User \(id.uuidString.prefix(5))" : name }
    
    public init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
}
