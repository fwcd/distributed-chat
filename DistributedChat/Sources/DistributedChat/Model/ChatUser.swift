import Foundation

public struct ChatUser: Identifiable, Hashable, Codable {
    public let id: UUID
    public var name: String?
    
    public var displayName: String { name ?? "<user \(id.uuidString.prefix(5))>" }
    
    public init(id: UUID = UUID(), name: String? = nil) {
        self.id = id
        self.name = name
    }
}
