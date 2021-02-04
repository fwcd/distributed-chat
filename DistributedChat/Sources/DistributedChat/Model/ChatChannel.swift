import Foundation

public enum ChatChannel: Codable, Hashable {
    /// A public chatroom-style channel.
    case room(String)
    /// A direct messaging channel with another user (whose id is specified here).
    case dm(UUID)
    
    public enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    public enum ChannelError: Error {
        case unknownType(String)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "room":
            self = .room(try container.decode(String.self, forKey: .data))
        case "dm":
            self = .dm(try container.decode(UUID.self, forKey: .data))
        default:
            throw ChannelError.unknownType("Unknown channel type \(type)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .room(let name):
            try container.encode("room", forKey: .type)
            try container.encode(name, forKey: .data)
        case .dm(let userId):
            try container.encode("dm", forKey: .type)
            try container.encode(userId, forKey: .data)
        }
    }
}
