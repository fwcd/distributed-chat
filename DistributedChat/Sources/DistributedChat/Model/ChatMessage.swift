import Crypto
import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatMessage")

public struct ChatMessage: Identifiable, Hashable, Codable {
    public let id: UUID
    public var timestamp: Date // TODO: Specify time zone?
    public var author: ChatUser
    public var content: ChatMessageContent
    public var channel: ChatChannel?
    public var attachments: [ChatAttachment]?
    public var repliedToMessageId: UUID?

    public var isEncrypted: Bool { content.isEncrypted || (attachments?.contains(where: \.isEncrypted) ?? false) }
    public var dmRecipientId: UUID? {
        if case let .dm(userIds) = channel, userIds.count == 2, userIds.contains(author.id) {
            return userIds.first { $0 != author.id }
        }
        return nil
    }
    
    public var displayContent: String {
        content.description
    }
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        author: ChatUser,
        content: ChatMessageContent,
        channel: ChatChannel? = nil,
        attachments: [ChatAttachment]? = nil,
        repliedToMessageId: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
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

    /// Encrypts a message for the recipient if it's a two-person DM.
    public func encryptedIfNeeded(with sender: ChatCryptoKeys.Private, keyFinder: (UUID) -> ChatCryptoKeys.Public?) -> ChatMessage {
        if let recipientId = dmRecipientId, let recipientKeys = keyFinder(recipientId) {
            do {
                return try encrypted(with: sender, for: recipientKeys)
            } catch {
                log.warning("Could not encrypt message: \(self)")
            }
        }
        return self
    }

    /// Decrypts a message from the author if it's a two-person DM.
    public func decryptedIfNeeded(with recipient: ChatCryptoKeys.Private, keyFinder: (UUID) -> ChatCryptoKeys.Public?) -> ChatMessage {
        if isEncrypted, let senderKeys = keyFinder(author.id) {
            do {
                return try decrypted(with: recipient, from: senderKeys)
            } catch {
                log.debug("Could not decrypt message: \(self)")
            }
        }
        return self
    }

    public func encrypted(with sender: ChatCryptoKeys.Private, for recipient: ChatCryptoKeys.Public) throws -> ChatMessage {
        guard !isEncrypted else { throw ChatCryptoError.alreadyEncrypted }
        guard let data = content.asText?.data(using: .utf8) else { throw ChatCryptoError.nonEncodableText }

        var newMessage = self
        newMessage.content = .encrypted(try sender.encrypt(plain: data, for: recipient))
        newMessage.attachments = try attachments?.map { try $0.encrypted(with: sender, for: recipient) }

        return newMessage
    }

    public func decrypted(with recipient: ChatCryptoKeys.Private, from sender: ChatCryptoKeys.Public) throws -> ChatMessage {
        guard case let .encrypted(cipherData) = content else { throw ChatCryptoError.alreadyEncrypted }
        guard let text = try String(data: recipient.decrypt(cipher: cipherData, by: sender), encoding: .utf8) else { throw ChatCryptoError.nonEncodableText }

        var newMessage = self
        newMessage.content = .text(text)
        newMessage.attachments = try attachments?.map { try $0.decrypted(with: recipient, from: sender) }

        return newMessage
    }
}
