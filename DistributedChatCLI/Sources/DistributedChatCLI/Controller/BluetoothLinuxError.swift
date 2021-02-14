public enum BluetoothLinuxError: Error {
    case tooFewHostControllers(String)
    case noServices
    case noCharacteristics
    case bleScanFailed(String)
}
