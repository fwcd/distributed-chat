#if os(Linux)
import DistributedChat
import Logging
import Bluetooth
import BluetoothLinux

fileprivate let log = Logger(label: "BluetoothLinuxTransport")

public struct BluetoothLinuxTransport: ChatTransport {
    private let l2CapServer: L2CAPSocket

    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController.identifier) with address \(try! hostController.readDeviceAddress())")

        l2CapServer = try L2CAPSocket.lowEnergyServer()
        log.info("Opened L2CAP server with PSM \(l2CapServer.protocolServiceMultiplexer)")
    }

    public func broadcast(_ raw: String) {
        // TODO
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

