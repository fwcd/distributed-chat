public enum ChatCryptoError: Error {
    case invalidBase64(String)
    case invalidSignature
    case couldNotDecode(String)
    case alreadyEncrypted
    case alreadyDecrypted
}
