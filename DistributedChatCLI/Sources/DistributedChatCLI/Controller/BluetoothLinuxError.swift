public enum BluetoothLinuxError: Error {
    case noHostController
    case noServices
    case noCharacteristics
    case bleScanFailed(String)
}
