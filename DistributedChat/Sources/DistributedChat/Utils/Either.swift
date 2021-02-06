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

extension Either: ExpressibleByUnicodeScalarLiteral where L: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: L.UnicodeScalarLiteralType) {
        self = .left(L.init(unicodeScalarLiteral: value))
    }
}

extension Either: ExpressibleByExtendedGraphemeClusterLiteral where L: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: L.ExtendedGraphemeClusterLiteralType) {
        self = .left(L.init(extendedGraphemeClusterLiteral: value))
    }
}

extension Either: ExpressibleByStringLiteral where L: ExpressibleByStringLiteral {
    public init(stringLiteral value: L.StringLiteralType) {
        self = .left(L.init(stringLiteral: value))
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
