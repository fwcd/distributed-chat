import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var data: Data?                       // only if unencrypted
    public var cipherData: ChatCryptoCipherData? // only if encrypted
    public var compression: Compression?

    public var isEncrypted: Bool { cipherData != nil }
    
    public init(
        id: UUID = UUID(),
        type: ChatAttachmentType = .file,
        name: String,
        data: Data? = nil,
        cipherData: ChatCryptoCipherData? = nil,
        compression: Compression? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.data = data
        self.cipherData = cipherData
        self.compression = compression
    }
    
    public enum Compression: Int, Codable, Hashable {
        case lzfse = 0
        case lz4 = 1
        case lzma = 2
        case zlib = 3
    }

    public func encrypt(with sender: ChatCryptoKeys.Private, for recipient: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard let plain = data else { throw ChatCryptoError.alreadyEncrypted }
        var newAttachment = self
        newAttachment.data = nil
        newAttachment.cipherData = try sender.encrypt(plain: plain, for: recipient)
        return newAttachment
    }

    public func decrypt(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard let cipher = cipherData else { throw ChatCryptoError.alreadyEncrypted }
        var newAttachment = self
        newAttachment.data = try recipient.decrypt(cipher: cipher, by: sender)
        newAttachment.cipherData = nil
        return newAttachment
    }
}
