import Crypto
import Foundation

public struct ChatMessage: Identifiable, Hashable, Codable {
    public let id: UUID
    public var timestamp: Date // TODO: Specify time zone?
    public var author: ChatUser
    public var content: String
    public var encryptedContent: ChatCryptoCipherData?
    public var channel: ChatChannel?
    public var attachments: [ChatAttachment]?
    public var repliedToMessageId: UUID?

    public var isEncrypted: Bool { encryptedContent != nil || (attachments?.contains(where: \.isEncrypted) ?? false) }
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        author: ChatUser,
        content: String = "",
        encryptedContent: ChatCryptoCipherData? = nil,
        channel: ChatChannel? = nil,
        attachments: [ChatAttachment]? = nil,
        repliedToMessageId: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
        self.encryptedContent = encryptedContent
        self.channel = channel
        self.attachments = attachments
        self.repliedToMessageId = repliedToMessageId
    }
    
    /// Checks whether the given user id should receive the message.
    public func isReceived(by userId: UUID) -> Bool {
        switch channel {
        case .dm(let userIds)?:
            return userIds.contains(userId)
        default:
            return true
        }
    }

    /// Encrypts a message for the recipients if its a DM.
    public func encryptedIfNeeded() throws -> ChatMessage? {
        // TODO
        nil
    }

    public func encrypted(with sender: ChatCryptoKeys.Private, for recipient: ChatCryptoKeys.Public) throws -> ChatMessage {
        guard !isEncrypted else { throw ChatCryptoError.alreadyEncrypted }
        guard let plainData = content.data(using: .utf8) else { throw ChatCryptoError.nonEncodableText }

        var newMessage = self
        newMessage.content = ""
        newMessage.encryptedContent = try sender.encrypt(plain: plainData, for: recipient)
        newMessage.attachments = try attachments?.map { try $0.encrypted(with: sender, for: recipient) }

        return newMessage
    }

    public func decrypted(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatMessage {
        guard let cipher = encryptedContent else { throw ChatCryptoError.alreadyEncrypted }
        guard let plainContent = try String(data: recipient.decrypt(cipher: cipher, by: sender), encoding: .utf8) else { throw ChatCryptoError.nonEncodableText }

        var newMessage = self
        newMessage.content = plainContent
        newMessage.encryptedContent = nil
        newMessage.attachments = try attachments?.map { try $0.decrypted(with: recipient, from: sender) }

        return newMessage
    }
}
