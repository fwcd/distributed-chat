import DistributedChatSimulationProtocol
import Foundation
import NIO
import Vapor

fileprivate let log = Logger(label: "ClientManager")
fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

class MessagingHandler {
    private var clients: [UUID: ClientState] = [:]
    private var linkReliability: Double = 1.0 // from 0 (never transmit) to 1 (always transmit)
    private var linkDelay: Double = 0.0       // in seconds

    private class ClientState {
        private let ws: WebSocket
        var name: String? = nil
        var links: Set<UUID> = []
        var isObserver: Bool = false

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

        ws.onText { [weak self] _, raw in
            do {
                let message = try decoder.decode(SimulationProtocol.Message.self, from: raw.data(using: .utf8)!)
                try self?.handleReceive(from: uuid, message: message)
            } catch {
                log.error("Error while handling '\(raw)' from \(uuid): \(error)")
            }
        }

        ws.onClose.whenComplete { [weak self] _ in
            do {
                try self?.handleClose(uuid)
            } catch {
                log.error("Error while closing connection to \(uuid): \(error)")
            }
            self?.clients[uuid] = nil
            log.info("Closed connection to \(uuid)")
        }
    }

    private func handleReceive(from sender: UUID, message: SimulationProtocol.Message) throws {
        let senderClient = clients[sender]!

        switch message {
        case .hello(let hello):
            senderClient.name = hello.name
            for (_, client) in clients where client.isObserver {
                try client.send(.helloNotification(.init(name: hello.name, uuid: "\(sender)")))
            }
            log.info("Hello, \(hello.name)!")
        
        case .observe:
            senderClient.isObserver = true
            try sendClientsAndLinks(to: sender)
            try sendLinkConfiguration(to: sender)
            log.info("\(name(of: sender)) is now an observer!")

        case .addLink(let link):
            if let fromUUID = UUID(uuidString: link.fromUUID),
               let toUUID = UUID(uuidString: link.toUUID),
               let fromClient = clients[fromUUID],
               let toClient = clients[toUUID] {
                fromClient.links.insert(toUUID)
                toClient.links.insert(fromUUID)
                for (_, client) in clients where client.isObserver {
                    try client.send(.addLinkNotification(link))
                }
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
                for (_, client) in clients where client.isObserver {
                    try client.send(.removeLinkNotification(link))
                }
                log.info("Removed link from \(name(of: fromUUID)) to \(name(of: toUUID))")
            } else {
                log.error("Could not remove link, invalid UUID(s)")
            }
        
        case .setLinkReliability(let linkReliability):
            self.linkReliability = linkReliability
            for (id, client) in clients where client.isObserver && id != sender {
                try client.send(.setLinkReliabilityNotification(linkReliability))
            }

        case .setLinkDelay(let linkDelay):
            self.linkDelay = linkDelay
            for (id, client) in clients where client.isObserver && id != sender {
                try client.send(.setLinkReliabilityNotification(linkReliability))
            }

        case .broadcast(let broadcast):
            let eventLoop = group.next()
            eventLoop.scheduleTask(deadline: .now() + .milliseconds(Int64(linkDelay * 1000))) { [weak self] in
                guard let this = self else { return }
                if Double.random(in: 0..<1) < this.linkReliability {
                    let observers = this.clients.values.filter(\.isObserver)
                    for uuid in senderClient.links {
                        if let client = this.clients[uuid] {
                            let notification = SimulationProtocol.Message.broadcastNotification(.init(
                                content: broadcast.content,
                                link: .init(fromUUID: "\(sender)", toUUID: "\(uuid)")
                            ))
                            try client.send(notification)
                            for observer in observers {
                                try observer.send(notification)
                            }
                        }
                    }
                    log.info("Broadcasted '\(broadcast.content)' from \(this.name(of: sender))")
                }
            }

        default:
            log.info("Unexpected message \(message) from \(name(of: sender))")
        }
    }

    private func handleClose(_ sender: UUID) throws {
        if let name = clients[sender]?.name {
            for (_, client) in clients where client.isObserver {
                try client.send(.goodbyeNotification(.init(name: name, uuid: "\(sender)")))
            }
        }
    }

    private func sendClientsAndLinks(to sender: UUID) throws {
        // Inform the client about other
        // clients that have already identified themselves
        // with a hello message and their links (while
        // making sure that no duplicate links are emitted).

        var sentLinks: Set<Set<UUID>> = []
        let senderClient = clients[sender]!

        for (uuid, client) in clients {
            if let name = client.name {
                try senderClient.send(.helloNotification(.init(name: name, uuid: "\(uuid)")))

                for linked in client.links where !sentLinks.contains([uuid, linked]) {
                    try senderClient.send(.addLinkNotification(.init(fromUUID: "\(uuid)", toUUID: "\(linked)")))
                    sentLinks.insert([uuid, linked])
                }
            }
        }
    }

    private func sendLinkConfiguration(to sender: UUID) throws {
        let senderClient = clients[sender]!

        try senderClient.send(.setLinkReliabilityNotification(linkReliability))
        try senderClient.send(.setLinkDelayNotification(linkDelay))
    }

    private func name(of uuid: UUID) -> String {
        clients[uuid]?.name ?? "\(uuid)"
    }
}
