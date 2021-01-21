/// The central structure of the distributed chat.
/// Carries out actions, e.g. on the user's behalf.
public struct ChatController {
    private let transport: ChatTransport

    public init(transport: ChatTransport) {
        self.transport = transport
    }
}
