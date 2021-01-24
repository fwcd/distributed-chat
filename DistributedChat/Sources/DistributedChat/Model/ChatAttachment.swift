import Foundation

public struct ChatAttachment: Codable, Hashable {
    var name: String
    var url: URL // use data-URLs for embedding data directly
    
    public init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
