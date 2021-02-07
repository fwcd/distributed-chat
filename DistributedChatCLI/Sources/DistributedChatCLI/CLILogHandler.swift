import Logging

struct CLILogHandler: LogHandler {
    let label: String
    var logLevel: Logger.Level
    var metadata: Logger.Metadata = [:]

    init(label: String, logLevel: Logger.Level = .info) {
        self.label = label
        self.logLevel = logLevel
    }

    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let shortLabel = label.split(separator: ".").last.map(String.init) ?? label
        print("\r> \(shortLabel): \(message)\r")
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }
}
