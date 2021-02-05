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

    private let privateKeys = ChatCryptoKeys.Private()
    private var presenceTimer: RepeatingTimer?
    public private(set) var presence: ChatPresence

    public var me: ChatUser { presence.user }

    public init(me: ChatUser = ChatUser(), transport: ChatTransport) {
        presence = ChatPresence(user: me)
        
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
        
        for message in protoMessage.addedChatMessages ?? [] where message.isReceived(by: me.id) {
            for listener in addChatMessageListeners {
                listener(message)
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

        let protoMessage = ChatProtocol.Message(addedChatMessages: [chatMessage])
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
}
