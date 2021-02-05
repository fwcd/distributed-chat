import Crypto
import Foundation

// Based on CryptoKit sample from https://developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
// BSD-3-licensed, Copyright 2020 Apple Inc.

fileprivate let salt = "DistributedChat.ChatCrypto".data(using: .utf8)!

public struct ChatCryptoKeys {
    public let publicKeys: Public
    public let privateKeys: Private

    public struct Public: Codable {
        public let encryptionKey: Curve25519.KeyAgreement.PublicKey
        public let signingKey: Curve25519.Signing.PublicKey

        public enum CodingKeys: String, CodingKey {
            case encryptionKey = "e"
            case signingKey = "s"
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

        /// Encrypts data for the given recipient's public keys using
        /// X25519 key agreement, ed25519 signatures and the symmetric
        /// ChaCha20-Poly1305 cipher.
        public func encrypt(plain: Data, for recipient: Public) throws -> ChatCryptoCipherData {
            let ephemeralKey = Curve25519.KeyAgreement.PrivateKey()
            let ephemeralPublicKey = ephemeralKey.publicKey
            let sharedSecret = try ephemeralKey.sharedSecretFromKeyAgreement(with: recipient.encryptionKey)

            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: salt,
                sharedInfo: ephemeralPublicKey.rawRepresentation
                    + recipient.signingKey.rawRepresentation
                    + signingKey.publicKey.rawRepresentation,
                outputByteCount: 32
            )

            let sealed = try ChaChaPoly.seal(plain, using: symmetricKey).combined
            let signature = try signingKey.signature(for: sealed + ephemeralPublicKey.rawRepresentation + recipient.encryptionKey.rawRepresentation)
            return ChatCryptoCipherData(sealed: sealed, signature: signature, ephemeralPublicKey: ephemeralPublicKey.rawRepresentation)
        }

        /// Decrypts data from the given sender's public keys using
        /// X25519 key agreement, ed25519 signatures and the symmetric
        /// ChaCha20-Poly1305 cipher.
        public func decrypt(cipher: ChatCryptoCipherData, by sender: Public) throws -> Data {
            guard sender.signingKey.isValidSignature(cipher.signature, for: cipher.sealed + cipher.ephemeralPublicKey + encryptionKey.publicKey.rawRepresentation) else {
                throw ChatCryptoError.invalidSignature
            }

            let ephemeralPublicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: cipher.ephemeralPublicKey)
            let sharedSecret = try encryptionKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)

            let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: salt,
                sharedInfo: ephemeralPublicKey.rawRepresentation
                    + signingKey.publicKey.rawRepresentation
                    + sender.signingKey.rawRepresentation,
                outputByteCount: 32
            )

            let box = try ChaChaPoly.SealedBox(combined: cipher.sealed)
            return try ChaChaPoly.open(box, using: symmetricKey)
        }
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
