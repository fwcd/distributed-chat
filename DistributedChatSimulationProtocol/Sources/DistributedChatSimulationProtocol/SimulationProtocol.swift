public enum SimulationProtocol {
    // client -> server
    public struct Hello: Codable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    // server -> client
    public struct HelloNotification: Codable {
        public let name: String
        public let uuid: String

        public init(name: String, uuid: String) {
            self.name = name
            self.uuid = uuid
        }
    }

    // server -> client
    public struct GoodbyeNotification: Codable {
        public let name: String
        public let uuid: String
        
        public init(name: String, uuid: String) {
            self.name = name
            self.uuid = uuid
        }
    }

    // client -> server
    public struct Broadcast: Codable {
        public let content: String
        
        public init(content: String) {
            self.content = content
        }
    }

    // server -> client
    public struct BroadcastNotification: Codable {
        public let content: String

        public init(content: String) {
            self.content = content
        }
    }

    // bidirectional
    public enum Message: Codable {
        // client -> server
        case hello(Hello)
        case broadcast(Broadcast)

        // server -> client
        case helloNotification(HelloNotification)
        case goodbyeNotification(GoodbyeNotification)
        case broadcastNotification(BroadcastNotification)

        public enum CodingKeys: String, CodingKey {
            case type
            case data
        }

        public enum MessageError: Error {
            case unknownType(String)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "hello":
                self = .hello(try container.decode(Hello.self, forKey: .data))
            case "broadcast":
                self = .broadcast(try container.decode(Broadcast.self, forKey: .data))
            case "helloNotification":
                self = .helloNotification(try container.decode(HelloNotification.self, forKey: .data))
            case "goodbyeNotification":
                self = .goodbyeNotification(try container.decode(GoodbyeNotification.self, forKey: .data))
            case "broadcastNotification":
                self = .broadcastNotification(try container.decode(BroadcastNotification.self, forKey: .data))
            default:
                throw MessageError.unknownType(type)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .hello(let hello):
                try container.encode("hello", forKey: .type)
                try container.encode(hello, forKey: .data)
            case .broadcast(let broadcast):
                try container.encode("broadcast", forKey: .type)
                try container.encode(broadcast, forKey: .data)
            case .helloNotification(let helloNotification):
                try container.encode("helloNotification", forKey: .type)
                try container.encode(helloNotification, forKey: .data)
            case .goodbyeNotification(let goodbyeNotification):
                try container.encode("goodbyeNotification", forKey: .type)
                try container.encode(goodbyeNotification, forKey: .data)
            case .broadcastNotification(let broadcastNotification):
                try container.encode("broadcastNotification", forKey: .type)
                try container.encode(broadcastNotification, forKey: .data)
            }
        }
    }
}
