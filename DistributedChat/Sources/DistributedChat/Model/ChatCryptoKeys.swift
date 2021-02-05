import Crypto
import Foundation

public struct ChatCryptoKeys {
    public let publicKeys: Public
    public let privateKeys: Private

    public struct Public: Codable {
        public let encryptionKey: Curve25519.KeyAgreement.PublicKey
        public let signingKey: Curve25519.Signing.PublicKey

        public enum CodingKeys: String, CodingKey {
            case encryptionKey
            case signingKey
        }

        init(
            encryptionKey: Curve25519.KeyAgreement.PublicKey,
            signingKey: Curve25519.Signing.PublicKey
        ) {
            self.encryptionKey = encryptionKey
            self.signingKey = signingKey
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let base64EncryptionKey = try container.decode(String.self, forKey: .encryptionKey)
            let base64SigningKey = try container.decode(String.self, forKey: .signingKey)

            guard let rawEncryptionKey = Data(base64Encoded: base64EncryptionKey) else { throw ChatCryptoError.invalidBase64(base64EncryptionKey) }
            guard let rawSigningKey = Data(base64Encoded: base64SigningKey) else { throw ChatCryptoError.invalidBase64(base64SigningKey) }

            encryptionKey = try .init(rawRepresentation: rawEncryptionKey)
            signingKey = try .init(rawRepresentation: rawSigningKey)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            let rawEncryptionKey = encryptionKey.rawRepresentation
            let rawSigningKey = signingKey.rawRepresentation

            let base64EncryptionKey = rawEncryptionKey.base64EncodedString()
            let base64SigningKey = rawSigningKey.base64EncodedString()

            try container.encode(base64EncryptionKey, forKey: .encryptionKey)
            try container.encode(base64SigningKey, forKey: .signingKey)
        }
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
