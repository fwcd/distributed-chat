public class MockTransport: ChatTransport {
    public init() {}
    
    public func broadcast(_ raw: String) {}
    
    public func onReceive(_ handler: @escaping (String) -> Void) {}
}
