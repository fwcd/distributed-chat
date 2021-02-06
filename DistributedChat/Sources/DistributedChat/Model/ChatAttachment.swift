import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var content: Either3<URL, ChatCryptoCipherData, Data>
    public var compression: Compression?

    public var data: Data? { content.asRight }
    public var encryptedData: ChatCryptoCipherData? { content.asCenter }
    public var url: URL? { content.asLeft }
    public var isEncrypted: Bool { content.isRight }
    
    public init(
        id: UUID = UUID(),
        type: ChatAttachmentType = .file,
        name: String,
        content: Either3<URL, ChatCryptoCipherData, Data>,
        compression: Compression? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.content = content
        self.compression = compression
    }
    
    public enum Compression: Int, Codable, Hashable {
        case lzfse = 0
        case lz4 = 1
        case lzma = 2
        case zlib = 3
    }

    public func encrypted(with sender: ChatCryptoKeys.Private, for recipient: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard let plain = data else { throw ChatCryptoError.alreadyEncrypted }

        var newAttachment = self
        newAttachment.content = .center(try sender.encrypt(plain: plain, for: recipient))

        return newAttachment
    }

    public func decrypted(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard let cipher = encryptedData else { throw ChatCryptoError.alreadyEncrypted }

        var newAttachment = self
        newAttachment.content = .right(try recipient.decrypt(cipher: cipher, by: sender))

        return newAttachment
    }
}
