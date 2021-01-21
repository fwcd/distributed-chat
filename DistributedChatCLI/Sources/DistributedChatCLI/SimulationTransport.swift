import DistributedChat
import Foundation
import NIO
import WebSocketKit

fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

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

    public func broadcast(_ raw: String) {
        ws.send(raw)
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        ws.onText { _, raw in
            handler(raw)
        }
    }

    deinit {
        try! ws.close().wait()
    }
}
