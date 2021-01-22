#if os(Linux)
import DistributedChat
import Logging
import Bluetooth
import BluetoothLinux

fileprivate let log = Logger(label: "BluetoothLinuxTransport")

public struct BluetoothLinuxTransport: ChatTransport {
    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController)")
    }

    public func broadcast(_ raw: String) {
        // TODO
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

