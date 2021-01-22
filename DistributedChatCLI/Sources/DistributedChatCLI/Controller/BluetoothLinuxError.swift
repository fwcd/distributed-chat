public enum BluetoothLinuxError: Error {
    case noHostController
    case bleScanFailed(String)
}
