public enum Either<L, R> {
    case left(L)
    case right(R)
    
    var asLeft: L? {
        if case .left(let left) = self { return left }
        return nil
    }
    var asRight: R? {
        if case .right(let right) = self { return right }
        return nil
    }
    var isLeft: Bool { asLeft != nil }
    var isRight: Bool { asRight != nil }
}

extension Either: Equatable where L: Equatable, R: Equatable {}

extension Either: Hashable where L: Hashable, R: Hashable {}

extension Either: ExpressibleByUnicodeScalarLiteral where R: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: R.UnicodeScalarLiteralType) {
        self = .right(R.init(unicodeScalarLiteral: value))
    }
}

extension Either: ExpressibleByExtendedGraphemeClusterLiteral where R: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: R.ExtendedGraphemeClusterLiteralType) {
        self = .right(R.init(extendedGraphemeClusterLiteral: value))
    }
}

extension Either: ExpressibleByStringLiteral where R: ExpressibleByStringLiteral {
    public init(stringLiteral value: R.StringLiteralType) {
        self = .right(R.init(stringLiteral: value))
    }
}

extension Either: Codable where L: Codable, R: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(L.self) {
            self = .left(left)
        } else if let right = try? container.decode(R.self) {
            self = .right(right)
        } else {
            throw DecodeError.couldNotDecode
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
