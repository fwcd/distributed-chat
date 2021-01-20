import Foundation
import Vapor

fileprivate let log = Logger(label: "ClientManager")
fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

class MessagingHandler {
    private var clients: [UUID: ClientState] = [:]

    private struct ClientState {
        let ws: WebSocket
        var name: String? = nil
    }

    func connect(_ ws: WebSocket) {
        let uuid = UUID()
        clients[uuid] = ClientState(ws: ws)

        log.info("Opened connection to \(uuid)")

        ws.onText { _, raw in
            do {
                let message = try decoder.decode(MessagingProtocol.Message.self, from: raw.data(using: .utf8)!)
                try self.onReceive(from: uuid, message: message)
            } catch {
                log.error("Error while handling '\(raw)': \(error)")
            }
        }

        ws.onClose.whenComplete { _ in
            log.info("Closed connection to \(uuid)")
            self.clients[uuid] = nil
        }
    }

    private func onReceive(from senderUuid: UUID, message: MessagingProtocol.Message) throws {
        switch message {
        case .hello(let hello):
            clients[senderUuid]!.name = hello.name
            log.info("Hello, \(hello.name)!")
        case .broadcast(let broadcast):
            let notification = MessagingProtocol.Message.notification(.init(content: broadcast.content))
            for (uuid, client) in clients where uuid != senderUuid {
                client.ws.send(String(data: try encoder.encode(notification), encoding: .utf8)!)
            }
            log.info("Broadcasted '\(broadcast.content)' from \(clients[senderUuid]!.name ?? "\(senderUuid)")")
        default:
            log.info("Unexpected message: \(message)")
        }
    }
}
