import DistributedChat
import DistributedChatSimulationProtocol
import Foundation
import Logging
import NIO
import WebSocketKit

fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let log = Logger(label: "SimulationTransport")

public class SimulationTransport: ChatTransport {
    private let ws: WebSocket

    private init(ws: WebSocket) {
        self.ws = ws
    }

    /// Asynchronously connects to the given URL.
    public static func connect(url: URL, _ handler: @escaping (SimulationTransport) -> Void) {
        let _ = WebSocket.connect(to: url, on: group) { ws in
            handler(SimulationTransport(ws: ws))
        }
    }

    public func broadcast(_ content: String) {
        do {
            let protoMessage = SimulationProtocol.Message.broadcast(.init(content: content))
            ws.send(String(data: try encoder.encode(protoMessage), encoding: .utf8)!)
        } catch {
            log.error("Could not encode simulation protocol message: \(error)")
        }
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        ws.onText { _, raw in
            do {
                let protoMessage = try decoder.decode(SimulationProtocol.Message.self, from: raw.data(using: .utf8)!)
                if case let .broadcast(bc) = protoMessage {
                    handler(bc.content)
                }
            } catch {
                log.error("Could not decode simulation protocol message: \(error)")
            }
        }
    }

    deinit {
        try! ws.close().wait()
    }
}
