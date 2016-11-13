enum Pointer {
    case `struct`(Struct)
    case list(List)

    init?(scanner: Scanner, in message: Message) {
        // the pointer is the first word of the object
        let pointer = scanner.current(as: UInt64.self)

        if pointer == 0 {
            return nil
        }

        // the first two bits of the pointer describe the type of the object
        switch pointer.bitRange(0..<2) {
        case 0:
            self = .struct(Struct(scanner: scanner, in: message))
        case 1:
            self = .list(List(scanner: scanner, in: message))
        case 2:
            guard let resolved = FarPointer.resolve(scanner: scanner, in: message) else {
                return nil
            }
            self = resolved

        // logic error, so fatalerror instead of returning nil
        default: fatalError("unknown type")
        }
    }

    var list: List? {
        switch self {
        case let .list(list): return list
        default: return nil
        }
    }

    var `struct`: Struct? {
        switch self {
        case let .struct(`struct`): return `struct`
        default: return nil
        }
    }
}
