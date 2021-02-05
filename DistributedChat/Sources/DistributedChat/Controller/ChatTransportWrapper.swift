import Foundation
import Logging

fileprivate let encoder = makeJSONEncoder()
fileprivate let decoder = makeJSONDecoder()
fileprivate let log = Logger(label: "DistributedChat.ChatTransportWrapper")

/// An abstraction of the transport layer that
/// operates on (JSON-)codable types rather than
/// strings.
@available(iOS 13, *)
class ChatTransportWrapper<T> where T: Codable & Identifiable {
    private let transport: ChatTransport
    private var receiveListeners: [(T) -> Void] = []
    private var receivedProtoMessages: Set<T.ID> = []

    init(transport: ChatTransport)  {
        self.transport = transport
        
        transport.onReceive { [unowned self] json in
            do {
                let protoMessage = try decoder.decode(T.self, from: json.data(using: .utf8)!)

                if !receivedProtoMessages.contains(protoMessage.id) {
                    receivedProtoMessages.insert(protoMessage.id)
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
    func broadcast(_ protoMessage: T) {
        do {
            receivedProtoMessages.insert(protoMessage.id)

            let json = String(data: try encoder.encode(protoMessage), encoding: .utf8)!
            transport.broadcast(json)
        } catch {
            log.error("Could not encode protocol message: \(error)")
        }
    }

    /// Adds a handler that is fired whenever a protocol message is
    /// received from a node in reach.
    func onReceive(_ handler: @escaping (T) -> Void) {
        receiveListeners.append(handler)
    }
}
