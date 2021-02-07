import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatController")

/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
@available(iOS 13, *)
public class ChatController {
    private let transportWrapper: ChatTransportWrapper
    private var addChatMessageListeners: [(ChatMessage) -> Void] = []
    private var updatePresenceListeners: [(ChatPresence) -> Void] = []
    private var deleteMessageListeners: [(ChatDeletion) -> Void] = []
    private var userFinders: [(UUID) -> ChatUser?] = []
    public var emitAllReceivedChatMessages: Bool = false // including encrypted ones/those not for me
    private var protoMessageStorage: ChatProtocolMessageStorage = ChatProtocolMessageListStorage(size: 100)

    private let privateKeys: ChatCryptoKeys.Private
    private var presenceTimer: RepeatingTimer?
    public private(set) var presence: ChatPresence {
        didSet {
            for listener in updatePresenceListeners {
                listener(presence)
            }
        }
    }

    public var me: ChatUser { presence.user }

    public init(me: ChatUser = ChatUser(), transport: ChatTransport) {
        let privateKeys = ChatCryptoKeys.Private()
        self.privateKeys = privateKeys

        presence = ChatPresence(user: me)
        presence.user.publicKeys = privateKeys.publicKeys
        
        transportWrapper = ChatTransportWrapper(myUserId: me.id, transport: transport)
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
        
        for presence in protoMessage.updatedPresences ?? [] {
            for listener in updatePresenceListeners {
                listener(presence)
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
            logicalClock: presence.user.logicalClock
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
        presence.user.logicalClock = max(presence.user.logicalClock, logicalClock) + 1
    }
    
    public func update(name: String) {
        presence.user.name = name
    }

    private func findUser(for userId: UUID) -> ChatUser? {
        userFinders.lazy.compactMap { $0(userId) }.first
    }

    private func findPublicKeys(for userId: UUID) -> ChatCryptoKeys.Public? {
        findUser(for: userId)?.publicKeys
    }

    private func handle(request: ChatProtocol.MessageRequest) {
        for protoMessage in buildProtoMessagesFrom(request: request) {
            broadcast(protoMessage)
        }
    }
    
    private func broadcastPresence() {
        log.debug("Broadcasting presence: \(presence.status) (\(presence.info))")
        broadcast(ChatProtocol.Message(
            sourceUserId: me.id,
            updatedPresences: [presence],
            logicalClock: presence.user.logicalClock
        ), store: true)
    }

    private func broadcast(_ protoMessage: ChatProtocol.Message, store: Bool = false) {
        transportWrapper.broadcast(protoMessage)
        if store {
            protoMessageStorage.store(message: protoMessage)
        }
        presence.user.logicalClock += 1
    }

    private func buildMessageRequest() -> ChatProtocol.MessageRequest {
        var request = ChatProtocol.MessageRequest()
        for item in protoMessageStorage.getStoredMessages(required: nil) {
            request.vectorTime[item.sourceUserId] = item.logicalClock
        }
        return request
    }

    private func buildProtoMessagesFrom(request: ChatProtocol.MessageRequest) -> [ChatProtocol.Message] {
        var messages = [ChatProtocol.Message]()
        for (userId, clock) in request.vectorTime {
            messages += protoMessageStorage.getStoredMessages { $0.sourceUserId == userId && $0.logicalClock > clock }
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
