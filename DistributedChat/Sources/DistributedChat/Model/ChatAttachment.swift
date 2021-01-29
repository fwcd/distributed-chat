import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var url: URL // use data-URLs for embedding data directly
    
    public init(id: UUID = UUID(), type: ChatAttachmentType = .file, name: String, url: URL) {
        self.id = id
        self.type = type
        self.name = name
        self.url = url
    }
}
