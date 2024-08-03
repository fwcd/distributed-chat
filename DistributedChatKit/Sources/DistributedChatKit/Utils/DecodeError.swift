public enum DecodeError: Error {
    case couldNotDecode
    case missingChannelData
    case unknownType(String)
}
