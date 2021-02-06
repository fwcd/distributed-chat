import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var content: ChatAttachmentContent
    public var compression: Compression?

    public var isEncrypted: Bool { content.asEncrypted != nil }
    
    public init(
        id: UUID = UUID(),
        type: ChatAttachmentType = .file,
        name: String,
        content: ChatAttachmentContent,
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
        if case .url(_) = content { throw ChatCryptoError.urlIsNotEncryptable }
        guard case let .data(plain) = content else { throw ChatCryptoError.alreadyEncrypted }

        var newAttachment = self
        newAttachment.content = .encrypted(try sender.encrypt(plain: plain, for: recipient))

        return newAttachment
    }

    public func decrypted(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard case let .encrypted(cipherData) = content else { throw ChatCryptoError.alreadyEncrypted }

        var newAttachment = self
        newAttachment.content = .data(try recipient.decrypt(cipher: cipherData, by: sender))

        return newAttachment
    }
}
