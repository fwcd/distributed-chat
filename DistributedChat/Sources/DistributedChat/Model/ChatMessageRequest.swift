import Foundation

public struct ChatMessageRequest {
    // Resembles the newest timestamp from a received message for a speciifc author
    public var vectorTime: Dictionary<UUID,Int>
}