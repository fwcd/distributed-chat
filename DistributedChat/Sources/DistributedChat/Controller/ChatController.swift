import Foundation
import Logging

fileprivate let log = Logger(label: "ChatController")

/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
public class ChatController {
    private let transportWrapper: ChatTransportWrapper<ChatProtocol.Message>
    private var addChatMessageListeners: [(ChatMessage) -> Void] = []

    public private(set) var me = ChatUser()

    public init(transport: ChatTransport) {
        transportWrapper = ChatTransportWrapper(transport: transport)
        transportWrapper.onReceive(handleReceive)
    }

    private func handleReceive(_ protoMessage: ChatProtocol.Message) {
        // TODO: Rebroadcast message and make sure that
        //       incoming messages did NOT origin from us
        //       (i.e. went in a loop), as otherwise the
        //       listeners would be fired twice with this
        //       message.

        for message in protoMessage.addedChatMessages {
            for listener in addChatMessageListeners {
                listener(message)
            }
        }
    }

    public func send(content: String, on channelName: String? = nil, attaching attachmentUrls: [URL]? = nil, replyingTo repliedToMessageId: UUID? = nil) {
        let chatMessage = ChatMessage(
            author: me,
            content: content,
            channelName: channelName,
            attachmentUrls: attachmentUrls,
            repliedToMessageId: repliedToMessageId
        )
        
        transportWrapper.broadcast(ChatProtocol.Message(addedChatMessages: [chatMessage]))
        
        for listener in addChatMessageListeners {
            listener(chatMessage)
        }
    }

    public func update(name: String) {
        me.name = name

        // TODO: Broadcast name change to others?
    }

    public func onAddChatMessage(_ handler: @escaping (ChatMessage) -> Void) {
        addChatMessageListeners.append(handler)
    }
}
