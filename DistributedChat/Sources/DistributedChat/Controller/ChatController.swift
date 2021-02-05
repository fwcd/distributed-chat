import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatController")

/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
@available(iOS 13, *)
public class ChatController {
    private let transportWrapper: ChatTransportWrapper<ChatProtocol.Message>
    private var addChatMessageListeners: [(ChatMessage) -> Void] = []
    private var updatePresenceListeners: [(ChatPresence) -> Void] = []
    private var userFinders: [(UUID) -> ChatUser?] = []
    public var emitAllReceivedChatMessages: Bool = false // including encrypted ones/those not for me

    private let privateKeys: ChatCryptoKeys.Private
    private var presenceTimer: RepeatingTimer?
    public private(set) var presence: ChatPresence

    public var me: ChatUser { presence.user }

    public init(me: ChatUser = ChatUser(), transport: ChatTransport) {
        let privateKeys = ChatCryptoKeys.Private()
        self.privateKeys = privateKeys

        presence = ChatPresence(user: me)
        presence.user.publicKeys = privateKeys.publicKeys
        
        transportWrapper = ChatTransportWrapper(transport: transport)
        transportWrapper.onReceive(handleReceive)
        
        // Broadcast the presence every 10 seconds
        presenceTimer = RepeatingTimer(interval: 10.0) { [weak self] in
            self?.broadcastPresence()
        }
    }

    private func handleReceive(_ protoMessage: ChatProtocol.Message) {
        // TODO: Expire old proto message ids to reduce memory consumption?
        //       Attach ttls and/or 'actual' expiry datetimes to messages?
        
        // TODO: Logical/vector clocks to ensure consistent ordering? This
        //       is especially important for destructive operations like
        //       presence updates (which overwrite the old presence).

        // Rebroadcast message
        
        transportWrapper.broadcast(protoMessage)
        
        // Handle messages for me
        
        for encryptedMessage in protoMessage.addedChatMessages ?? [] where encryptedMessage.isReceived(by: me.id) || emitAllReceivedChatMessages {
            let chatMessage = encryptedMessage.decryptedIfNeeded(with: privateKeys, keyFinder: findPublicKeys(for:))

            for listener in addChatMessageListeners {
                listener(chatMessage)
            }
        }
        
        // Handle presence updates
        
        for presence in protoMessage.updatedPresences ?? [] {
            for listener in updatePresenceListeners {
                listener(presence)
            }
        }
    }

    public func send(content: String, on channel: ChatChannel? = nil, attaching attachments: [ChatAttachment]? = nil, replyingTo repliedToMessageId: UUID? = nil) {
        let chatMessage = ChatMessage(
            author: me,
            content: content,
            channel: channel,
            attachments: attachments,
            repliedToMessageId: repliedToMessageId
        )
        let encryptedMessage = chatMessage.encryptedIfNeeded(with: privateKeys, keyFinder: findPublicKeys(for:))
        let protoMessage = ChatProtocol.Message(addedChatMessages: [encryptedMessage])

        transportWrapper.broadcast(protoMessage)
        
        for listener in addChatMessageListeners {
            listener(chatMessage)
        }
    }

    public func update(presence: ChatPresence) {
        self.presence = presence
        
        for listener in updatePresenceListeners {
            listener(presence)
        }
    }
    
    public func update(name: String) {
        var newPresence = presence
        newPresence.user.name = name
        update(presence: newPresence)
    }

    private func findUser(for userId: UUID) -> ChatUser? {
        userFinders.lazy.compactMap { $0(userId) }.first
    }

    private func findPublicKeys(for userId: UUID) -> ChatCryptoKeys.Public? {
        findUser(for: userId)?.publicKeys
    }
    
    private func broadcastPresence() {
        log.debug("Broadcasting presence: \(presence.status) (\(presence.info))")
        transportWrapper.broadcast(ChatProtocol.Message(updatedPresences: [presence]))
    }
    
    public func onAddChatMessage(_ handler: @escaping (ChatMessage) -> Void) {
        addChatMessageListeners.append(handler)
    }
    
    public func onUpdatePresence(_ handler: @escaping (ChatPresence) -> Void) {
        updatePresenceListeners.append(handler)
    }

    public func onFindUser(_ handler: @escaping (UUID) -> ChatUser?) {
        userFinders.append(handler)
    }
}
