import Foundation
import Vapor

fileprivate let log = Logger(label: "ClientManager")

class MessagingHandler {
    private var clients: [UUID: WebSocket] = [:]

    func connect(_ ws: WebSocket) {
        let uuid = UUID()
        clients[uuid] = ws

        log.info("Opened connection to \(uuid)")

        ws.onText { _, text in
            // Echo text
            ws.send(text)
        }

        ws.onClose.whenComplete { _ in
            log.info("Closed connection to \(uuid)")
            self.clients[uuid] = nil
        }
    }
}
