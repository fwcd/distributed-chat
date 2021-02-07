import Foundation

public struct ChatMessageRequest: Hashable, Codable {
    /// Resembles the newest timestamp from a received message for a specific author
    public var vectorTime: [UUID: Int] = [:]
}
