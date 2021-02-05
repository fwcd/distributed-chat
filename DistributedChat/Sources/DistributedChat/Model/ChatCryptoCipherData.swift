import Crypto
import Foundation

public struct ChatCryptoCipherData: Codable {
    public let sealed: Data
    public let signature: Data
    public let ephemeralPublicKey: Data

    public init(sealed: Data, signature: Data, ephemeralPublicKey: Data) {
        self.sealed = sealed
        self.signature = signature
        self.ephemeralPublicKey = ephemeralPublicKey
    }
}
