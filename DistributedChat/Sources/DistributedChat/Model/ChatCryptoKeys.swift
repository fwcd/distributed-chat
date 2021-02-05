import Crypto
import Foundation

public struct ChatCryptoKeys {
    public let publicKeys: Public
    public let privateKeys: Private

    public struct Public {
        public let encryptionKey: Curve25519.KeyAgreement.PublicKey
        public let signingKey: Curve25519.Signing.PublicKey
    }

    public struct Private {
        public let encryptionKey: Curve25519.KeyAgreement.PrivateKey
        public let signingKey: Curve25519.Signing.PrivateKey
    }

    public init() {
        let privateEncryptionKey = Curve25519.KeyAgreement.PrivateKey()
        let privateSigningKey = Curve25519.Signing.PrivateKey()

        publicKeys = .init(
            encryptionKey: privateEncryptionKey.publicKey,
            signingKey: privateSigningKey.publicKey
        )
        privateKeys = .init(
            encryptionKey: privateEncryptionKey,
            signingKey: privateSigningKey
        )
    }
}
