public enum SimulationProtocol {
    // client -> server
    public struct Hello: Codable {
        public let name: String

        public init(name: String) {
            self.name = name
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
    public struct Notification: Codable {
        public let content: String

        public init(content: String) {
            self.content = content
        }
    }

    // bidirectional
    public enum Message: Codable {
        case hello(Hello)
        case broadcast(Broadcast)
        case notification(Notification)

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
            case "notification":
                self = .notification(try container.decode(Notification.self, forKey: .data))
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
            case .notification(let notification):
                try container.encode("notification", forKey: .type)
                try container.encode(notification, forKey: .data)
            }
        }
    }
}
