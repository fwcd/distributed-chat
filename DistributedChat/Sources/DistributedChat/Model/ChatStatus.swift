public enum ChatStatus: String, Codable, Hashable, CaseIterable, CustomStringConvertible {
    case online = "Online"
    case away = "Away"
    case busy = "Busy"
    
    public var description: String { rawValue }
}
