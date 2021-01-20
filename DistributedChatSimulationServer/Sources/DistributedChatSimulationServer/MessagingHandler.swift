import Foundation
import Vapor

fileprivate let log = Logger(label: "ClientManager")
fileprivate let decoder = JSONDecoder()

class MessagingHandler {
    private var clients: [UUID: WebSocket] = [:]

    func connect(_ ws: WebSocket) {
        let uuid = UUID()
        clients[uuid] = ws

        log.info("Opened connection to \(uuid)")

        ws.onText { _, raw in
            do {
                let msg = try decoder.decode(MessagingProtocol.Message.self, from: raw.data(using: .utf8)!)
                log.info("Got \(msg)")
            } catch {
                log.error("Invalid protocol message: \(raw) - \(error)")
            }
        }

        ws.onClose.whenComplete { _ in
            log.info("Closed connection to \(uuid)")
            self.clients[uuid] = nil
        }
    }
}
