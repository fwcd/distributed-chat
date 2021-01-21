import Foundation
import Logging

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let log = Logger(label: "ChatController")

/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
public class ChatController {
    private let transport: ChatTransport

    public init(transport: ChatTransport) {
        self.transport = transport

        transport.onReceive { [unowned self] raw in
            do {
                let protoMessage = try decoder.decode(ChatProtocol.Message.self, from: raw.data(using: .utf8)!)
                onReceive(protoMessage)
            } catch {
                log.error("Could not decode chat protocol message: \(error)")
            }
        }
    }

    private func send(_ protoMessage: ChatProtocol.Message) {
        do {
            transport.broadcast(String(data: try encoder.encode(protoMessage), encoding: .utf8)!)
        } catch {
            log.error("Could not encode chat protocol message: \(error)")
        }
    }

    private func onReceive(_ protoMessage: ChatProtocol.Message) {
        // TODO
        log.info("Received: \(protoMessage)")
    }
}
