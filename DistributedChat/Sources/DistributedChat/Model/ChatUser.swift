import Foundation

public struct ChatUser: Codable {
    public var uuid: UUID
    public var name: String?
    
    public init(uuid: UUID = UUID(), name: String? = nil) {
        self.uuid = uuid
        self.name = name
    }
}
