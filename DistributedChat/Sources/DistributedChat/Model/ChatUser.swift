import Foundation

public struct ChatUser: Codable {
    public var uuid: UUID = UUID()
    public var name: String? = nil
}
