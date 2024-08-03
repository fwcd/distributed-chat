public struct CoreBluetoothSettings: Codable {
    public var advertisingEnabled: Bool
    public var scanningEnabled: Bool
    public var monitorSignalStrength: Bool
    public var monitorSignalStrengthInterval: Int
    
    public init(
        advertisingEnabled: Bool = true,
        scanningEnabled: Bool = true,
        monitorSignalStrength: Bool = true,
        monitorSignalStrengthInterval: Int = 5 // seconds
    ) {
        self.advertisingEnabled = advertisingEnabled
        self.scanningEnabled = scanningEnabled
        self.monitorSignalStrength = monitorSignalStrength
        self.monitorSignalStrengthInterval = monitorSignalStrengthInterval
    }
}
