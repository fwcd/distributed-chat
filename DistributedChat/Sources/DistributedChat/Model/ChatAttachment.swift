import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var name: String
    public var url: URL // use data-URLs for embedding data directly
    
    public init(id: UUID = UUID(), name: String, url: URL) {
        self.id = id
        self.name = name
        self.url = url
    }
}
