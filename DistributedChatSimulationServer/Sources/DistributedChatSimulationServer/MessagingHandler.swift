import DistributedChatSimulationProtocol
import Foundation
import Vapor

fileprivate let log = Logger(label: "ClientManager")
fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

class MessagingHandler {
    private var clients: [UUID: ClientState] = [:]

    private class ClientState {
        private let ws: WebSocket
        var name: String? = nil
        var links: Set<UUID> = []

        init(ws: WebSocket) {
            self.ws = ws
        }

        func send(_ message: SimulationProtocol.Message) throws {
            ws.send(String(data: try encoder.encode(message), encoding: .utf8)!)
        }
    }

    func connect(_ ws: WebSocket) {
        let uuid = UUID()
        clients[uuid] = ClientState(ws: ws)

        log.info("Opened connection to \(uuid)")
        do {
            try self.onConnect(to: uuid)
        } catch {
            log.error("Error while opening connection to \(uuid): \(error)")
        }

        ws.onText { _, raw in
            do {
                let message = try decoder.decode(SimulationProtocol.Message.self, from: raw.data(using: .utf8)!)
                try self.onReceive(from: uuid, message: message)
            } catch {
                log.error("Error while handling '\(raw)' from \(uuid): \(error)")
            }
        }

        ws.onClose.whenComplete { _ in
            do {
                try self.onClose(uuid)
            } catch {
                log.error("Error while closing connection to \(uuid): \(error)")
            }
            self.clients[uuid] = nil
            log.info("Closed connection to \(uuid)")
        }
    }

    private func onConnect(to sender: UUID) throws {
        for (uuid, client) in clients {
            if let name = client.name {
                try clients[sender]?.send(.helloNotification(.init(name: name, uuid: "\(uuid)")))
            }
        }
    }

    private func onReceive(from sender: UUID, message: SimulationProtocol.Message) throws {
        switch message {
        case .hello(let hello):
            clients[sender]!.name = hello.name
            for (_, client) in clients {
                try client.send(.helloNotification(.init(name: hello.name, uuid: "\(sender)")))
            }
            log.info("Hello, \(hello.name)!")

        case .addLink(let link):
            if let fromUUID = UUID(uuidString: link.fromUUID),
               let toUUID = UUID(uuidString: link.toUUID),
               let fromClient = clients[fromUUID],
               let toClient = clients[toUUID] {
                fromClient.links.insert(toUUID)
                toClient.links.insert(fromUUID)
                log.info("Added link from \(name(of: fromUUID)) to \(name(of: toUUID))")
            } else {
                log.error("Could not create link, invalid UUID(s)")
            }
        
        case .removeLink(let link):
            if let fromUUID = UUID(uuidString: link.fromUUID),
               let toUUID = UUID(uuidString: link.toUUID),
               let fromClient = clients[fromUUID],
               let toClient = clients[toUUID] {
                fromClient.links.remove(toUUID)
                toClient.links.remove(fromUUID)
                log.info("Removed link from \(name(of: fromUUID)) to \(name(of: toUUID))")
            } else {
                log.error("Could not remove link, invalid UUID(s)")
            }

        case .broadcast(let broadcast):
            for (uuid, client) in clients where uuid != sender {
                try client.send(.broadcastNotification(.init(content: broadcast.content)))
            }
            log.info("Broadcasted '\(broadcast.content)' from \(name(of: sender))")

        default:
            log.info("Unexpected message \(message) from \(name(of: sender))")
        }
    }

    private func onClose(_ sender: UUID) throws {
        if let name = clients[sender]?.name {
            for (_, client) in clients {
                try client.send(.goodbyeNotification(.init(name: name, uuid: "\(sender)")))
            }
        }
    }

    private func name(of uuid: UUID) -> String {
        clients[uuid]?.name ?? "\(uuid)"
    }
}
