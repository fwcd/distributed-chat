import Foundation

public enum ChatChannel: Codable, Hashable, CustomStringConvertible {
    /// A public chatroom-style channel.
    case room(String)
    /// A direct messaging channel with another user (whose id is specified here).
    case dm(UUID)
    
    public var description: String {
        switch self {
        case .room(let name):
            return "room:\(name)"
        case .dm(let userId):
            return "dm:\(userId)"
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    public enum ChannelError: Error {
        case unknownType(String)
        case couldNotParse(String)
        case invalidUUID(String)
    }
    
    public init(parsing str: String) throws {
        let split = str.split(separator: ":", maxSplits: 1).map(String.init)
        guard split.count == 2 else { throw ChannelError.couldNotParse(str) }
        
        try self.init(type: split[0], data: split[1])
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let data = try container.decode(String.self, forKey: .data)
        
        try self.init(type: type, data: data)
    }
    
    private init(type: String, data: String) throws {
        switch type {
        case "room":
            self = .room(type)
        case "dm":
            guard let userId = UUID(uuidString: data) else { throw ChannelError.invalidUUID(data) }
            self = .dm(userId)
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
            try container.encode(userId.uuidString, forKey: .data)
        }
    }
}
