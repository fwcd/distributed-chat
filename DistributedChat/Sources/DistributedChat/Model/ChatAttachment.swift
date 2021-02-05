import Foundation

public struct ChatAttachment: Codable, Identifiable, Hashable {
    public var id: UUID
    public var type: ChatAttachmentType
    public var name: String
    public var data: Data
    public var compression: Compression?
    
    public init(id: UUID = UUID(), type: ChatAttachmentType = .file, name: String, data: Data, compression: Compression? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.data = data
        self.compression = compression
    }
    
    public enum Compression: Int, Codable, Hashable {
        case lzfse = 0
        case lz4 = 1
        case lzma = 2
        case zlib = 3
    }
}
