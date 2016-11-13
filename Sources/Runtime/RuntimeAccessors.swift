import Foundation

public extension Message {
    convenience init(data: Data) {
        self.init(scanner: Scanner(data: data as NSData))
    }

    func root<T: StructInitializable>() -> T {
        return T(storage: self.rootStruct)
    }
}

public protocol StructInitializable {
    init(storage: Struct)
}

public protocol UnionProtocol {
    init(tag: UInt16, storage: Struct)
}

public extension Struct {
    //data
    func value(at index: Int) -> Data? {
        guard
            let pointer = pointers[index],
            case let .list(list) = pointer
            else {
                return nil
        }
        precondition(list.elementSize == .byte1)
        
        let bytes = list.elements.map { $0.data.current(as: UInt8.self) }
        
        return Data(bytes: bytes)
    }

    //string
    func value(at index: Int) -> String? {
        guard let data: Data = value(at: index) else {
            return nil
        }
        guard data.count > 0 else {
            return ""
        }
        // remote null-terminater
        let stripped = data.subdata(in: data.startIndex..<data.endIndex - 1)
        return String(data: stripped, encoding: String.Encoding.utf8)
    }

    //bool
    func value(at index: Int) -> Bool {
        let bitOffset = index % 8
        let chunkOffset = index / 8 * 8
        
        let chunk = data.value(atBit: chunkOffset) as UInt8
        let bit = chunk.bitRange(bitOffset..<bitOffset+1)
        
        precondition(bit == 0 || bit == 1)
        return bit == 1
    }

    //union
    func value<T: UnionProtocol>(at index: Int) -> T {
        return T.init(tag: data.value(atBit: index), storage: self)
    }

    //enum
    func value<T: RawRepresentable>(at index: Int) -> T where T.RawValue == UInt16 {
        return T.init(rawValue: data.value(atBit: index))!
    }

    //group
    func value<T: StructInitializable>() -> T {
        return T.init(storage: self)
    }

    //list
    func value<T: StructInitializable>(at index: Int) -> [T]? {
        guard
            let pointer = pointers[index],
            case let .list(list) = pointer
            else {
                return nil
        }
        precondition(list.elementSize == .composite)
        return list.elements.map(T.init(storage:))
    }

    //struct
    func value<T: StructInitializable>(at index: Int) -> T? {
        guard
            let pointer = pointers[index],
            case let .struct(`struct`) = pointer
            else {
                return nil
        }
        return T.init(storage: `struct`)
    }

    //number
    func value<T: Integer>(at bit: Int) -> T {
        return data.value(atBit: bit)
    }

    //float
    func value<T: FloatingPoint>(at bit: Int) -> T {
        return data.value(atBit: bit)
    }
}


//public extension Struct {
//    //TODO: replace all of these with a single `get` to make code gen easier
//    func data(at index: Int) -> Data? {
//        guard
//            let pointer = pointers[index],
//            case let .list(list) = pointer
//            else {
//            return nil
//        }
//        precondition(list.elementSize == .byte1)
//
//        let bytes = list.elements.map { $0.data.current(as: UInt8.self) }
//
//        return Data(bytes: bytes)
//    }
//
//    func string(at index: Int) -> String? {
//        guard let data = data(at: index) else {
//            return nil
//        }
//        guard data.count > 0 else {
//            return ""
//        }
//        // remote null-terminater
//        let stripped = data.subdata(in: data.startIndex..<data.endIndex - 1)
//        return String(data: stripped, encoding: String.Encoding.utf8)
//    }
//
//    func bool(at index: Int) -> Bool {
//        let bitOffset = index % 8
//        let chunkOffset = index / 8 * 8
//
//        let chunk = data.value(atBit: chunkOffset) as UInt8
//        let bit = chunk.bitRange(bitOffset..<bitOffset+1)
//
//        precondition(bit == 0 || bit == 1)
//        return bit == 1
//    }
//
//    func union<T: UnionProtocol>(at index: Int) -> T {
//        return T.init(tag: data.value(atBit: index), storage: self)
//    }
//
//    func `enum`<T: RawRepresentable>(at index: Int) -> T where T.RawValue == UInt16 {
//        return T.init(rawValue: data.value(atBit: index))!
//    }
//
//    func group<T: StructInitializable>() -> T {
//        return T.init(storage: self)
//    }
//
//    func list<T: StructInitializable>(at index: Int) -> [T]? {
//        guard
//            let pointer = pointers[index],
//            case let .list(list) = pointer
//            else {
//            return nil
//        }
//        precondition(list.elementSize == .composite)
//        return list.elements.map(T.init(storage:))
//    }
//
//    func `struct`<T: StructInitializable>(at index: Int) -> T? {
//        guard
//            let pointer = pointers[index],
//            case let .struct(`struct`) = pointer
//            else {
//            return nil
//        }
//        return T.init(storage: `struct`)
//    }
//
//    func value<T>(at bit: Int) -> T {
//        return data.value(atBit: bit)
//    }
//}
