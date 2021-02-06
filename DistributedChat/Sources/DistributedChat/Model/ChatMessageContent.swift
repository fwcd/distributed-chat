public enum ChatMessageContent: Hashable, Codable, ExpressibleByStringLiteral {
    case text(String)
    case encrypted(ChatCryptoCipherData)

    var asText: String? {
        guard case let .text(text) = self else { return nil }
        return text
    }
    var asEncrypted: ChatCryptoCipherData? {
        guard case let .encrypted(cipherData) = self else { return nil }
        return cipherData
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(stringLiteral: String) {
        self = .text(stringLiteral)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "text":
            self = .text(try container.decode(String.self, forKey: .data))
        case "encrypted":
            self = .encrypted(try container.decode(ChatCryptoCipherData.self, forKey: .data))
        default:
            throw DecodeError.unknownType(type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .data)
        case .encrypted(let encrypted):
            try container.encode("encrypted", forKey: .type)
            try container.encode(encrypted, forKey: .data)
        }
    }
}
