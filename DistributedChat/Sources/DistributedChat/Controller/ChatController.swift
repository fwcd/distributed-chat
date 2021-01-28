import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChat.ChatController")

/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
public class ChatController {
    private let transportWrapper: ChatTransportWrapper<ChatProtocol.Message>
    private var addChatMessageListeners: [(ChatMessage) -> Void] = []

    private var presenceTimer: RepeatingTimer?
    public private(set) var presence = ChatPresence()
    public var me: ChatUser { presence.user }

    public init(transport: ChatTransport) {
        transportWrapper = ChatTransportWrapper(transport: transport)
        transportWrapper.onReceive(handleReceive)
        
        // Broadcast the presence every 10 seconds
        presenceTimer = RepeatingTimer(interval: 10.0) { [weak self] in
            self?.broadcastPresence()
        }
    }

    private func handleReceive(_ protoMessage: ChatProtocol.Message) {
        // TODO: Rebroadcast message and make sure that
        //       incoming messages did NOT origin from us
        //       (i.e. went in a loop), as otherwise the
        //       listeners would be fired twice with this
        //       message.

        for message in protoMessage.addedChatMessages ?? [] {
            for listener in addChatMessageListeners {
                listener(message)
            }
        }
    }

    public func send(content: String, on channelName: String? = nil, attaching attachments: [ChatAttachment]? = nil, replyingTo repliedToMessageId: UUID? = nil) {
        let chatMessage = ChatMessage(
            author: me,
            content: content,
            channelName: channelName,
            attachments: attachments,
            repliedToMessageId: repliedToMessageId
        )
        
        transportWrapper.broadcast(ChatProtocol.Message(addedChatMessages: [chatMessage]))
        
        for listener in addChatMessageListeners {
            listener(chatMessage)
        }
    }

    public func update(presence: ChatPresence) {
        self.presence = presence
    }
    
    public func update(name: String) {
        var newPresence = presence
        newPresence.user.name = name
        update(presence: newPresence)
    }
    
    private func broadcastPresence() {
        log.info("Broadcasting presence: \(presence.status) (\(presence.info)")
        transportWrapper.broadcast(ChatProtocol.Message(updatedPresences: [presence]))
    }

    public func onAddChatMessage(_ handler: @escaping (ChatMessage) -> Void) {
        addChatMessageListeners.append(handler)
    }
}
