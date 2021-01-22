import Foundation

public struct ChatUser: Identifiable, Codable {
    public let id: UUID
    public var name: String?
    
    public init(id: UUID = UUID(), name: String? = nil) {
        self.id = id
        self.name = name
    }
}
