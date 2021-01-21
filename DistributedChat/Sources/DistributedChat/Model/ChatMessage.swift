import Foundation

public struct ChatMessage: Codable {
    public let author: ChatUser
    public let timestamp: Date
    public let content: String
}
