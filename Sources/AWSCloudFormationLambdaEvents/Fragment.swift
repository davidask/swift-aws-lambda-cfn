@dynamicMemberLookup
public enum Fragment {
    case map([String: Fragment])
    case list([Fragment])
    case integer(Int)
    case float(Float)
    case string(String)
    case bool(Bool)
}

public extension Fragment {

    subscript(dynamicMember member: String) -> Self? {
        guard case .map(let value) = self else {
            return nil
        }

        return value[member]
    }

    subscript(index: Int) -> Self? {
        guard case .list(let value) = self else {
            return nil
        }

        return value[index]
    }
}

public extension Fragment {
    var map: [String: Self]? {
        guard case .map(let value) = self else {
            return nil
        }

        return value
    }

    var list: [Self]? {
        guard case .list(let value) = self else {
            return nil
        }

        return value
    }

    var integer: Int? {
        guard case .integer(let value) = self else {
            return nil
        }

        return value
    }

    var float: Float? {
        guard case .float(let value) = self else {
            return nil
        }

        return value
    }

    var string: String? {
        guard case .string(let value) = self else {
            return nil
        }

        return value
    }

    var bool: Bool? {
        guard case .bool(let value) = self else {
            return nil
        }

        return value
    }
}

public extension Fragment {
    enum FragmentError: Error {
        case unwrapFailed
    }
}

extension Fragment: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let map = try? container.decode([String: Fragment].self) {
            self = .map(map)
        } else if let list = try? container.decode([Fragment].self) {
            self = .list(list)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Float.self) {
            self = .float(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type \(container.codingPath)")
        }
    }
}

