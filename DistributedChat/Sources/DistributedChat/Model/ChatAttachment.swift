import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var url: URL?                            // \
    public var data: Data?                          //  |- mutually exclusive
    public var encryptedData: ChatCryptoCipherData? // /
    public var compression: Compression?

    public var isEncrypted: Bool { encryptedData != nil }
    
    public init(
        id: UUID = UUID(),
        type: ChatAttachmentType = .file,
        name: String,
        url: URL? = nil,
        data: Data? = nil,
        encryptedData: ChatCryptoCipherData? = nil,
        compression: Compression? = nil
    ) {
        // Enforce mutual exclusion
        assert([url as Any, data as Any, encryptedData as Any].compactMap { $0 }.count == 1)

        self.id = id
        self.type = type
        self.name = name
        self.url = url
        self.data = data
        self.encryptedData = encryptedData
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
        newAttachment.data = nil
        newAttachment.encryptedData = try sender.encrypt(plain: plain, for: recipient)

        return newAttachment
    }

    public func decrypted(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatAttachment {
        guard let cipher = encryptedData else { throw ChatCryptoError.alreadyEncrypted }

        var newAttachment = self
        newAttachment.data = try recipient.decrypt(cipher: cipher, by: sender)
        newAttachment.encryptedData = nil

        return newAttachment
    }
}
