public enum SimulationProtocol {
    public struct Hello: Codable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct HelloOrGoodbyeWithUUID: Codable {
        public let name: String
        public let uuid: String

        public init(name: String, uuid: String) {
            self.name = name
            self.uuid = uuid
        }
    }

    public struct Broadcast: Codable {
        public let content: String

        public init(content: String) {
            self.content = content
        }
    }

    public struct Link: Codable {
        public let fromUUID: String
        public let toUUID: String

        public init(fromUUID: String, toUUID: String) {
            self.fromUUID = fromUUID
            self.toUUID = toUUID
        }
    }

    public enum Message: Codable {
        // client -> server
        case hello(Hello)
        case broadcast(Broadcast)
        case addLink(Link)
        case removeLink(Link)

        // server -> client
        case helloNotification(HelloOrGoodbyeWithUUID)
        case goodbyeNotification(HelloOrGoodbyeWithUUID)
        case addLinkNotification(Link)
        case removeLinkNotification(Link)
        case broadcastNotification(Broadcast)

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
            case "addLink":
                self = .addLink(try container.decode(Link.self, forKey: .data))
            case "removeLink":
                self = .removeLink(try container.decode(Link.self, forKey: .data))
            case "helloNotification":
                self = .helloNotification(try container.decode(HelloOrGoodbyeWithUUID.self, forKey: .data))
            case "goodbyeNotification":
                self = .goodbyeNotification(try container.decode(HelloOrGoodbyeWithUUID.self, forKey: .data))
            case "addLinkNotification":
                self = .addLinkNotification(try container.decode(Link.self, forKey: .data))
            case "removeLinkNotification":
                self = .removeLinkNotification(try container.decode(Link.self, forKey: .data))
            case "broadcastNotification":
                self = .broadcastNotification(try container.decode(Broadcast.self, forKey: .data))
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
            case .addLink(let addLink):
                try container.encode("addLink", forKey: .type)
                try container.encode(addLink, forKey: .data)
            case .removeLink(let removeLink):
                try container.encode("removeLink", forKey: .type)
                try container.encode(removeLink, forKey: .data)
            case .helloNotification(let helloNotification):
                try container.encode("helloNotification", forKey: .type)
                try container.encode(helloNotification, forKey: .data)
            case .goodbyeNotification(let goodbyeNotification):
                try container.encode("goodbyeNotification", forKey: .type)
                try container.encode(goodbyeNotification, forKey: .data)
            case .addLinkNotification(let addLinkNotification):
                try container.encode("addLinkNotification", forKey: .type)
                try container.encode(addLinkNotification, forKey: .data)
            case .removeLinkNotification(let removeLinkNotification):
                try container.encode("removeLinkNotification", forKey: .type)
                try container.encode(removeLinkNotification, forKey: .data)
            case .broadcastNotification(let broadcastNotification):
                try container.encode("broadcastNotification", forKey: .type)
                try container.encode(broadcastNotification, forKey: .data)
            }
        }
    }
}
