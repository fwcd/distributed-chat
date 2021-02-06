public enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either: Equatable where L: Equatable, R: Equatable {}

extension Either: Hashable where L: Hashable, R: Hashable {}

extension Either: Codable where L: Codable, R: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(L.self) {
            self = .left(left)
        } else if let right = try? container.decode(R.self) {
            self = .right(right)
        } else {
            throw EitherDecodingError.couldNotDecode
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .left(let left):
            try container.encode(left)
        case .right(let right):
            try container.encode(right)
        }
    }
}
