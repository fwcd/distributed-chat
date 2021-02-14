import ArgumentParser
import Logging

extension Logger.Level: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}
