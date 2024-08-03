public enum ChatStatus: String, Codable, Hashable, CaseIterable, CustomStringConvertible {
    case online = "Online"
    case away = "Away"
    case busy = "Busy"
    case offline = "Offline"
    
    public var description: String { rawValue }
}
