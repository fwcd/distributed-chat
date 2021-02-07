import Foundation
import Logging

fileprivate let encoder = makeJSONEncoder()
fileprivate let decoder = makeJSONDecoder()
fileprivate let log = Logger(label: "DistributedChat.ChatTransportWrapper")

/// An abstraction of the transport layer that
/// operates on (JSON-)codable protocol messages
/// rather than strings.
class ChatTransportWrapper {
    private let transport: ChatTransport
    private var receiveListeners: [(ChatProtocol.Message) -> Void] = []
    private var receivedProtoMessageIds: Set<UUID> = []

    init(myUserId: UUID, transport: ChatTransport)  {
        self.transport = transport
        
        transport.onReceive { [unowned self] json in
            do {
                let protoMessage = try decoder.decode(ChatProtocol.Message.self, from: json.data(using: .utf8)!)

                if protoMessage.isReceived(by: myUserId) && !receivedProtoMessageIds.contains(protoMessage.id) {
                    receivedProtoMessageIds.insert(protoMessage.id)
                    for listener in receiveListeners {
                        listener(protoMessage)
                    }
                }
            } catch {
                log.error("Could not decode protocol message: \(error)")
            }
        }
    }

    /// Sends a protocol message to all reachable nodes.
    func broadcast(_ protoMessage: ChatProtocol.Message) {
        do {
            receivedProtoMessageIds.insert(protoMessage.id)

            let json = String(data: try encoder.encode(protoMessage), encoding: .utf8)!
            transport.broadcast(json)
        } catch {
            log.error("Could not encode protocol message: \(error)")
        }
    }

    /// Adds a handler that is fired whenever a protocol message is
    /// received from a node in reach.
    func onReceive(_ handler: @escaping (ChatProtocol.Message) -> Void) {
        receiveListeners.append(handler)
    }
}
