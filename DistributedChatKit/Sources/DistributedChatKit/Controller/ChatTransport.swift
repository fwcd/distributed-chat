/// The transport layer used to perform all communication
/// with other nodes.
/// 
/// Could e.g. be based on Bluetooth LE in the real app
/// or the simulation protocol when used with the CLI.
public protocol ChatTransport {
    /// Sends a string to all reachable nodes.
    func broadcast(_ raw: String)

    /// Adds a handler that is fired whenever a string is
    /// received from a node in reach.
    func onReceive(_ handler: @escaping (String) -> Void)
}
