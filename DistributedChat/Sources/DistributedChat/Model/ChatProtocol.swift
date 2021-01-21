public enum ChatProtocol {
    public enum Message: Codable {
        case addMessage(ChatMessage)

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
            case "addMessage":
                self = .addMessage(try container.decode(ChatMessage.self, forKey: .data))
            default:
                throw MessageError.unknownType(type)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .addMessage(let message):
                try container.encode("addMessage", forKey: .type)
                try container.encode(message, forKey: .data)
            }
        }
    }
}
