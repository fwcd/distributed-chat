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
    private var deleteMessageListeners: [(ChatDeletion) -> Void] = []
    private var userFinders: [(UUID) -> ChatUser?] = []
    public var emitAllReceivedChatMessages: Bool = false // including encrypted ones/those not for me

    // Internal state
    private var protoMessageStorage: ChatProtocolMessageStorage = ChatProtocolMessageListStorage(size: 100)
    private var presences: [UUID: ChatPresence] = [:]

    private let privateKeys: ChatCryptoKeys.Private
    private var presenceTimer: RepeatingTimer?
    public private(set) var presence: ChatPresence {
        didSet {
            for listener in updatePresenceListeners {
                listener(presence)
            }
        }
    }

    public var me: ChatUser {
        get { presence.user }
        set { presence.user = newValue }
    }

    public init(me: ChatUser = ChatUser(), transport: ChatTransport) {
        let privateKeys = ChatCryptoKeys.Private()
        self.privateKeys = privateKeys

        presence = ChatPresence(user: me)
        presence.user.publicKeys = privateKeys.publicKeys
        
        transportWrapper = ChatTransportWrapper(transport: transport)
        transportWrapper.onReceive { [unowned self] in
            handleReceive($0)
        }
        
        // Broadcast the presence every 10 seconds
        presenceTimer = RepeatingTimer(interval: 10.0) { [weak self] in
            self?.broadcastPresence()
        }

        onDeleteMessage { [unowned self] in
            protoMessageStorage.deleteMessage(id: $0.messageId)
        }
    }

    private func handleReceive(_ protoMessage: ChatProtocol.Message) {
        // Rebroadcast message

        transportWrapper.broadcast(protoMessage)

        if protoMessage.isDestination(userId: me.id) {
            // Store message and update clock

            update(logicalClock: protoMessage.logicalClock)
            protoMessageStorage.store(message: protoMessage)

            // Handle message additions

            for encryptedMessage in protoMessage.addedChatMessages ?? [] where encryptedMessage.isReceived(by: me.id) || emitAllReceivedChatMessages {
                let chatMessage = encryptedMessage.decryptedIfNeeded(with: privateKeys, keyFinder: findPublicKeys(for:))

                if !chatMessage.isEncrypted || emitAllReceivedChatMessages {
                    for listener in addChatMessageListeners {
                        listener(chatMessage)
                    }
                }
            }

            // Handle presence updates
            
            for newPresence in protoMessage.updatedPresences ?? [] {
                let userId = newPresence.user.id
                let oldPresence = presences[userId]

                if oldPresence == nil {
                    // A new user is now reachable on the network,
                    // we therefore request the newest messages from
                    // him.

                    log.info("\(newPresence.user.displayName) is now reachable, we'll request messages from him...")
                    broadcast(ChatProtocol.Message(
                        sourceUserId: me.id,
                        destinationUserId: newPresence.user.id,
                        messageRequest: buildMessageRequest(),
                        logicalClock: me.logicalClock
                    ))
                }

                if oldPresence != newPresence {
                    presences[userId] = newPresence

                    for listener in updatePresenceListeners {
                        listener(newPresence)
                    }
                }
            }

            // Handle message deletions

            for deletion in protoMessage.deletedChatMessages ?? [] {
                for listener in deleteMessageListeners {
                    listener(deletion)
                }
            }

            // Handle protocol message requests

            if let request = protoMessage.messageRequest {
                handle(request: request)
            }
        }
    }

    public func send(content: String, on channel: ChatChannel? = nil, attaching attachments: [ChatAttachment]? = nil, replyingTo repliedToMessageId: UUID? = nil) {
        let chatMessage = ChatMessage(
            author: me,
            content: .text(content),
            channel: channel,
            attachments: attachments,
            repliedToMessageId: repliedToMessageId
        )
        let encryptedMessage = chatMessage.encryptedIfNeeded(with: privateKeys, keyFinder: findPublicKeys(for:))
        let protoMessage = ChatProtocol.Message(
            sourceUserId: me.id,
            addedChatMessages: [encryptedMessage],
            logicalClock: me.logicalClock
        )

        broadcast(protoMessage, store: true)
        
        for listener in addChatMessageListeners {
            listener(chatMessage)
        }
    }

    public func update(presence: ChatPresence) {
        self.presence = presence
    }

    private func update(logicalClock: Int) {
        me.logicalClock = max(me.logicalClock, logicalClock) + 1
    }
    
    public func update(name: String) {
        me.name = name
    }

    private func incrementClock() {
        me.logicalClock += 1
        log.debug("Logical clock: \(me.logicalClock)")
    }

    private func findUser(for userId: UUID) -> ChatUser? {
        userFinders.lazy.compactMap { $0(userId) }.first
    }

    private func findPublicKeys(for userId: UUID) -> ChatCryptoKeys.Public? {
        findUser(for: userId)?.publicKeys
    }

    private func handle(request: ChatProtocol.MessageRequest) {
        let protoMessages = buildProtoMessagesFrom(request: request)
        log.info("Sending out \(protoMessages.count) stored message(s) upon request...")
        for protoMessage in protoMessages {
            broadcast(protoMessage)
        }
    }
    
    private func broadcastPresence() {
        log.debug("Broadcasting presence: \(presence.status) (\(presence.info))")
        broadcast(ChatProtocol.Message(
            sourceUserId: me.id,
            updatedPresences: [presence],
            logicalClock: me.logicalClock
        ), store: true)
    }

    private func broadcast(_ protoMessage: ChatProtocol.Message, store: Bool = false) {
        transportWrapper.broadcast(protoMessage)
        if store {
            protoMessageStorage.store(message: protoMessage)
        }
        incrementClock()
    }

    private func buildMessageRequest() -> ChatProtocol.MessageRequest {
        let stored = protoMessageStorage.getStoredMessages(required: nil)
        let vectorTime = Dictionary(grouping: stored, by: { $0.sourceUserId })
            .mapValues { $0.last?.timestamp ?? .distantPast }
        return ChatProtocol.MessageRequest(vectorTime: vectorTime)
    }

    private func buildProtoMessagesFrom(request: ChatProtocol.MessageRequest) -> [ChatProtocol.Message] {
        var messages = [ChatProtocol.Message]()
        for (userId, timestamp) in request.vectorTime {
            messages += protoMessageStorage.getStoredMessages { $0.sourceUserId == userId && $0.timestamp > timestamp }
        }
        return messages
    }
    
    public func onAddChatMessage(_ handler: @escaping (ChatMessage) -> Void) {
        addChatMessageListeners.append(handler)
    }
    
    public func onUpdatePresence(_ handler: @escaping (ChatPresence) -> Void) {
        updatePresenceListeners.append(handler)
    }

    public func onDeleteMessage(_ handler: @escaping (ChatDeletion) -> Void) {
        deleteMessageListeners.append(handler)
    }

    public func onFindUser(_ handler: @escaping (UUID) -> ChatUser?) {
        userFinders.append(handler)
    }
}
