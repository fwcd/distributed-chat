import Foundation

public struct ChatMessageRequest {
    /// Resembles the newest timestamp from a received message for a specific author
    public var vectorTime: [UUID: Int]
}
