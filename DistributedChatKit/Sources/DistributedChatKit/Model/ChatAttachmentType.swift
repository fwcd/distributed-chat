public enum ChatAttachmentType: String, Codable, Hashable, CaseIterable, CustomStringConvertible {
    case file = "File"
    case image = "Image"
    case contact = "Contact"
    case voiceNote = "VoiceNote"
    
    public var description: String { rawValue }
}
