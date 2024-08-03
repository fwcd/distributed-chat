public enum Either3<L, C, R> {
    case left(L)
    case center(C)
    case right(R)
    
    var asLeft: L? {
        if case .left(let left) = self { return left }
        return nil
    }
    var asCenter: C? {
        if case .center(let center) = self { return center }
        return nil
    }
    var asRight: R? {
        if case .right(let right) = self { return right }
        return nil
    }
    var isLeft: Bool { asLeft != nil }
    var isCenter: Bool { asCenter != nil }
    var isRight: Bool { asRight != nil }
}

extension Either3: Equatable where L: Equatable, C: Equatable, R: Equatable {}

extension Either3: Hashable where L: Hashable, C: Hashable, R: Hashable {}

extension Either3: ExpressibleByUnicodeScalarLiteral where R: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: R.UnicodeScalarLiteralType) {
        self = .right(R.init(unicodeScalarLiteral: value))
    }
}

extension Either3: ExpressibleByExtendedGraphemeClusterLiteral where R: ExpressibleByStringLiteral {
    public init(extendedGraphemeClusterLiteral value: R.ExtendedGraphemeClusterLiteralType) {
        self = .right(R.init(extendedGraphemeClusterLiteral: value))
    }
}
extension Either3: ExpressibleByStringLiteral where R: ExpressibleByStringLiteral {
    public init(stringLiteral value: R.StringLiteralType) {
        self = .right(R.init(stringLiteral: value))
    }
}

extension Either3: Codable where L: Codable, C: Codable, R: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(L.self) {
            self = .left(left)
        } else if let center = try? container.decode(C.self) {
            self = .center(center)
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
        case .center(let center):
            try container.encode(center)
        case .right(let right):
            try container.encode(right)
        }
    }
}
