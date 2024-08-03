import DistributedChatKit
import Foundation

public struct NearbyUser: Identifiable, Hashable {
    public var peripheralIdentifier: UUID
    public var peripheralName: String?
    public var chatUser: ChatUser?
    public var rssi: Int?
    
    public var id: UUID { peripheralIdentifier }
    public var displayName: String { chatUser?.displayName ?? peripheralName ?? peripheralIdentifier.uuidString }
    
    public init(
        peripheralIdentifier: UUID,
        peripheralName: String? = nil,
        chatUser: ChatUser? = nil,
        rssi: Int? = nil // in db
    ) {
        self.peripheralIdentifier = peripheralIdentifier
        self.peripheralName = peripheralName
        self.chatUser = chatUser
        self.rssi = rssi
    }
}
