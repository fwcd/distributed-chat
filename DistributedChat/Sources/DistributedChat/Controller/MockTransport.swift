public class MockTransport: ChatTransport {
    private var listeners: [(String) -> Void] = []
    
    public init() {}
    
    public func broadcast(_ raw: String) {
        for listener in listeners {
            listener(raw)
        }
    }
    
    public func onReceive(_ handler: @escaping (String) -> Void) {
        listeners.append(handler)
    }
}
