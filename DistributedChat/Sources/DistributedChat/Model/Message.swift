import Foundation

public struct Message: Codable {
    public let author: User
    public let timestamp: Date
    public let content: String
}
