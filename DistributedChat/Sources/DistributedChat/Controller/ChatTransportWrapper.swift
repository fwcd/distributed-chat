import Foundation
import Logging

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let log = Logger(label: "ChatTransportWrapper")

/// An abstraction of the transport layer that
/// operates on (JSON-)codable types rather than
/// strings.
class ChatTransportWrapper<T> where T: Codable {
    private let transport: ChatTransport
    private var receiveListeners: [(T) -> Void] = []

    init(transport: ChatTransport)  {
        self.transport = transport

        transport.onReceive { [unowned self] json in
            do {
                let protoMessage = try decoder.decode(T.self, from: json.data(using: .utf8)!)
                for listener in receiveListeners {
                    listener(protoMessage)
                }
            } catch {
                log.error("Could not decode protocol message: \(error)")
            }
        }
    }

    func broadcast(_ protoMessage: T) {
        do {
            let json = String(data: try encoder.encode(protoMessage), encoding: .utf8)!
            transport.broadcast(json)
        } catch {
            log.error("Could not encode protocol message: \(error)")
        }
    }

    func onReceive(_ handler: @escaping (T) -> Void) {
        receiveListeners.append(handler)
    }
}
