import Foundation

public enum ChatAttachmentContent: Hashable, Codable {
    case url(URL)
    case encrypted(ChatCryptoCipherData)
    case data(Data)

    public var asURL: URL? {
        guard case let .url(url) = self else { return nil }
        return url
    }
    public var asEncrypted: ChatCryptoCipherData? {
        guard case let .encrypted(cipherData) = self else { return nil }
        return cipherData
    }
    public var asData: Data? {
        guard case let .data(data) = self else { return nil }
        return data
    }

    public var isURL: Bool { asURL != nil }
    public var isEncrypted: Bool { asEncrypted != nil }
    public var isData: Bool { asData != nil }

    public enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "url":
            self = .url(try container.decode(URL.self, forKey: .data))
        case "encrypted":
            self = .encrypted(try container.decode(ChatCryptoCipherData.self, forKey: .data))
        case "data":
            self = .data(try container.decode(Data.self, forKey: .data))
        default:
            throw DecodeError.unknownType(type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .url(let url):
            try container.encode("url", forKey: .type)
            try container.encode(url, forKey: .data)
        case .encrypted(let encrypted):
            try container.encode("encrypted", forKey: .type)
            try container.encode(encrypted, forKey: .data)
        case .data(let data):
            try container.encode("data", forKey: .type)
            try container.encode(data, forKey: .data)
        }
    }
}
