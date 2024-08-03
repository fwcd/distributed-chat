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
    private var deleteChatMessageListeners: [(ChatDeletion) -> Void] = []
    private var userFinders: [(UUID) -> ChatUser?] = []
    public var emitAllReceivedChatMessages: Bool = false // including encrypted ones/those not for me

    // Internal state
    private var messageCache: ChatMessageCache = ChatMessageListCache(size: 100)
    private var receivedMessageIds: Set<UUID> = []
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

        onAddChatMessage { [unowned self] in
            messageCache.store(message: $0)
        }

        onDeleteChatMessage { [unowned self] in
            messageCache.deleteMessage(id: $0.messageId)
        }
    }

    private func handleReceive(_ protoMessage: ChatProtocol.Message) {
        // Rebroadcast message

        transportWrapper.broadcast(protoMessage)

        if protoMessage.isDestination(userId: me.id) {
            // Store message and update clock

            update(logicalClock: protoMessage.logicalClock)

            // Handle message additions

            for encryptedMessage in protoMessage.addedChatMessages ?? [] where !receivedMessageIds.contains(encryptedMessage.id) && (encryptedMessage.isReceived(by: me.id) || emitAllReceivedChatMessages) {
                receivedMessageIds.insert(encryptedMessage.id)
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

                if oldPresence != newPresence {
                    presences[userId] = newPresence

                    for listener in updatePresenceListeners {
                        listener(newPresence)
                    }
                }

                if oldPresence == nil {
                    // A new user is now reachable on the network,
                    // we therefore request the newest messages.

                    log.debug("\(newPresence.user.displayName) is now reachable, we'll request messages...")
                    broadcast(ChatProtocol.Message(
                        sourceUserId: me.id,
                        messageRequest: buildMessageRequest(),
                        logicalClock: me.logicalClock
                    ))
                }
            }

            // Handle message deletions

            for deletion in protoMessage.deletedChatMessages ?? [] {
                for listener in deleteChatMessageListeners {
                    listener(deletion)
                }
            }

            // Handle protocol message requests

            if let request = protoMessage.messageRequest {
                handle(request: request, from: protoMessage.sourceUserId)
            }
        }
    }

    public func send(content: String, on channel: ChatChannel = .global, attaching attachments: [ChatAttachment]? = nil, replyingTo repliedToMessageId: UUID? = nil) {
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

        receivedMessageIds.insert(chatMessage.id)
        broadcast(protoMessage)
        
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

    public func update(me: ChatUser) {
        self.me = me
    }
    
    public func update(name: String) {
        me.name = name
    }

    private func incrementClock() {
        me.logicalClock += 1
        log.debug("Logical clock: \(me.logicalClock)")
    }

    private func findUser(for userId: UUID) -> ChatUser? {
        presences[userId]?.user ?? userFinders.lazy.compactMap { $0(userId) }.first
    }

    private func findPublicKeys(for userId: UUID) -> ChatCryptoKeys.Public? {
        findUser(for: userId)?.publicKeys
    }

    private func handle(request: ChatProtocol.MessageRequest, from userId: UUID) {
        let messages = buildMessagesFrom(request: request).sorted { $0.timestamp < $1.timestamp }
        if !messages.isEmpty {
            log.debug("Sending out \(messages.count) stored message(s) upon request from \(findUser(for: userId)?.displayName ?? "?")...")
            broadcast(ChatProtocol.Message(
                sourceUserId: me.id,
                addedChatMessages: messages,
                logicalClock: me.logicalClock
            ))
        }
    }
    
    private func broadcastPresence() {
        log.debug("Broadcasting presence: \(presence.status) (\(presence.info))")
        broadcast(ChatProtocol.Message(
            sourceUserId: me.id,
            updatedPresences: [presence],
            logicalClock: me.logicalClock
        ))
    }

    private func broadcast(_ protoMessage: ChatProtocol.Message) {
        transportWrapper.broadcast(protoMessage)
        incrementClock()
    }

    private func buildMessageRequest() -> ChatProtocol.MessageRequest {
        let stored = messageCache.getStoredMessages(required: nil)
        let vectorTime = Dictionary(uniqueKeysWithValues: presences.keys.map { ($0, Date.distantPast) })
            .merging(
                Dictionary(grouping: stored, by: { $0.author.id }).compactMapValues { $0.map(\.timestamp).max() },
                uniquingKeysWith: max
            )
        log.debug("Request vector: \(vectorTime)")
        return ChatProtocol.MessageRequest(vectorTime: vectorTime)
    }

    private func buildMessagesFrom(request: ChatProtocol.MessageRequest) -> [ChatMessage] {
        messageCache
            .getStoredMessages { $0.timestamp > (request.vectorTime[$0.author.id] ?? Date.distantPast) }
    }
    
    public func onAddChatMessage(_ handler: @escaping (ChatMessage) -> Void) {
        addChatMessageListeners.append(handler)
    }
    
    public func onUpdatePresence(_ handler: @escaping (ChatPresence) -> Void) {
        updatePresenceListeners.append(handler)
    }

    public func onDeleteChatMessage(_ handler: @escaping (ChatDeletion) -> Void) {
        deleteChatMessageListeners.append(handler)
    }

    public func onFindUser(_ handler: @escaping (UUID) -> ChatUser?) {
        userFinders.append(handler)
    }
}
