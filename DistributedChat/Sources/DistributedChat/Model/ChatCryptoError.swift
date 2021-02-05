public enum ChatCryptoError: Error {
    case invalidBase64(String)
    case invalidSignature
}
