#if os(Linux)
import DistributedChat
import Logging
import Bluetooth
import BluetoothHCI
import BluetoothLinux

fileprivate let log = Logger(label: "BluetoothLinuxTransport")

public struct BluetoothLinuxTransport: ChatTransport {
    private let l2CapServer: L2CAPSocket

    public init() throws {
        guard let hostController = BluetoothLinux.HostController.default else { throw BluetoothLinuxError.noHostController }
        log.info("Found host controller \(hostController.identifier) with address \(try! hostController.readDeviceAddress())")

        l2CapServer = try L2CAPSocket.lowEnergyServer()
        log.info("Opened L2CAP server with PSM \(l2CapServer.protocolServiceMultiplexer)")

        do {
            try hostController.lowEnergyScan(shouldContinue: { true }, foundDevice: handle(report:))
        } catch {
            throw BluetoothLinuxError.bleScanFailed("Try relaunching the application using sudo!")
        }
    }

    private func handle(report: HCILEAdvertisingReport.Report) {
        log.info("Got \(report.event)")
    }

    public func broadcast(_ raw: String) {
        // TODO
    }

    public func onReceive(_ handler: @escaping (String) -> Void) {
        // TODO
    }
}
#endif

