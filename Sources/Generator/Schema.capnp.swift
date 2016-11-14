import Runtime
import Foundation

enum ElementSize: UInt16 {
    case empty = 0
    case bit
    case byte
    case twoBytes
    case fourBytes
    case eightBytes
    case pointer
    case inlineComposite
}

struct Field: StructInitializable { // 24 bytes, 4 ptrs
    var storage: Struct

    enum Union: UnionProtocol {
        struct Slot: StructInitializable {
            var storage: Struct

            var offset: UInt32 { // bits[32, 64)
                get {
                    return storage.value(at: 32)
                }
            }
            var type: Type! { // ptr[2]
                get {
                    return storage.value(at: 2)
                }
            }
            var defaultValue: Value! { // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
            var hadExplicitDefault: Bool { // bits[128, 129)
                get {
                    return storage.value(at: 128)
                }
            }
        }
        struct Group: StructInitializable {
            var storage: Struct

            var typeId: UInt64 { // bits[128, 192)
                get {
                    return storage.value(at: 128)
                }
            }
        }

        case slot(Slot) // union tag = 0
        case group(Group) // union tag = 1

        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 0:
                self = .slot(Field.Union.Slot(storage: storage))
            case 1:
                self = .group(Field.Union.Group(storage: storage))
            default: fatalError()
            }
        }
    }
    struct Ordinal: StructInitializable {
        var storage: Struct

        enum Union: UnionProtocol {
            case implicit // bits[0, 0), union tag = 0
            case explicit(UInt16) // bits[96, 112), union tag = 1

            init(tag: UInt16, storage: Struct) {
                switch tag {
                case 0:
                    self = .implicit
                case 1:
                    self = .explicit(storage.value(at: 96))
                default: fatalError()
                }
            }
        }

        var union: Union { // tag bits [80, 96)
            get {
                return storage.value(at: 80)
            }
        }
    }

    var name: String! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }
    var codeOrder: UInt16 { // bits[0, 16)
        get {
            return storage.value(at: 0)
        }
    }
    var annotations: [Annotation]! { // ptr[1]
        get {
            return storage.value(at: 1)
        }
    }
    // TODO: how to handle this default?
    var discriminantValue: UInt16 { // = 65535 // bits[16, 32)
        get {
            return storage.value(at: 16) ^ 0xffff
        }
    }

    var union: Union { // tag bits [64, 80)
        get {
            return storage.value(at: 64)
        }
    }
    var ordinal: Ordinal {
        get {
            return storage.value()
        }
    }

    static let noDiscriminant: UInt16 = 0xffff;
}

struct Node: StructInitializable {
    var storage: Struct

    enum Union: UnionProtocol {
        struct Struct: StructInitializable {
            var storage: Runtime.Struct

            var dataWordCount: UInt16 { // bits[112, 128)
                get {
                    return storage.value(at: 112)
                }
            }
            var pointerCount: UInt16 { // bits[192, 208)
                get {
                    return storage.value(at: 192)
                }
            }
            var preferredListEncoding: ElementSize { // bits[208, 224)
                get {
                    return storage.value(at: 208)
                }
            }
            var isGroup: Bool { // bits[224, 225)
                get {
                    return storage.value(at: 224)
                }
            }
            var discriminantCount: UInt16 { // bits[240, 256)
                get {
                    return storage.value(at: 240)
                }
            }
            var discriminantOffset: UInt32 { // bits[256, 288)
                get {
                    return storage.value(at: 256)
                }
            }
            var fields: [Field]! { // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
        }
        struct Enum: StructInitializable {
            var storage: Runtime.Struct

            var enumerants: [Enumerant]! { // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
        }
        struct Interface: StructInitializable {
            var storage: Runtime.Struct

            var methods: [Method]! { // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
            var superclasses: [Superclass]! { // ptr[4]
                get {
                    return storage.value(at: 4)
                }
            }
        }
        struct Const: StructInitializable {
            var storage: Runtime.Struct

            var type: Type! { // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
            var value: Value! { // ptr[4]
                get {
                    return storage.value(at: 4)
                }
            }

        }
        struct Annotation {
            var storage: Runtime.Struct

            var type: Type! {  // ptr[3]
                get {
                    return storage.value(at: 3)
                }
            }
            var targetsFile: Bool {  // bits[112, 113)
                get {
                    return storage.value(at: 112)
                }
            }
            var targetsConst: Bool {  // bits[113, 114)
                get {
                    return storage.value(at: 113)
                }
            }
            var targetsEnum: Bool {  // bits[114, 115)
                get {
                    return storage.value(at: 114)
                }
            }
            var targetsEnumerant: Bool {  // bits[115, 116)
                get {
                    return storage.value(at: 115)
                }
            }
            var targetsStruct: Bool {  // bits[116, 117)
                get {
                    return storage.value(at: 116)
                }
            }
            var targetsField: Bool {  // bits[117, 118)
                get {
                    return storage.value(at: 117)
                }
            }
            var targetsUnion: Bool {  // bits[118, 119)
                get {
                    return storage.value(at: 118)
                }
            }
            var targetsGroup: Bool {  // bits[119, 120)
                get {
                    return storage.value(at: 119)
                }
            }
            var targetsInterface: Bool {  // bits[120, 121)
                get {
                    return storage.value(at: 120)
                }
            }
            var targetsMethod: Bool {  // bits[121, 122)
                get {
                    return storage.value(at: 121)
                }
            }
            var targetsParam: Bool {  // bits[122, 123)
                get {
                    return storage.value(at: 122)
                }
            }
            var targetsAnnotation: Bool {  // bits[123, 124)
                get {
                    return storage.value(at: 123)
                }
            }
        }

        case file // union tag = 0
        case `struct`(Struct) // union tag = 1
        case `enum`(Enum) // union tag = 2
        case interface(Interface) // union tag = 3
        case const(Const) // union tag = 4
        case annotation(Annotation) // union tag = 5

        init(tag: UInt16, storage: Runtime.Struct) {
            switch tag {
            case 0:
                self = .file
            case 1:
                self = .struct(Node.Union.Struct(storage: storage))
            case 2:
                self = .enum(Node.Union.Enum(storage: storage))
            case 3:
                self = .interface(Node.Union.Interface(storage: storage))
            case 4:
                self = .const(Node.Union.Const(storage: storage))
            case 5:
                self = .annotation(Node.Union.Annotation(storage: storage))

            default: fatalError()
            }
        }
    }
    struct Parameter: StructInitializable { // 0 bytes, 1 ptrs
        var storage: Struct

        var name: String! { // ptr[0]
            get {
                return storage.value(at: 0)
            }
        }
    }
    struct NestedNode: StructInitializable { // # 8 bytes, 1 ptrs
        var storage: Struct

        var name: String! { // ptr[0]
            get {
                return storage.value(at: 0)
            }
        }
        var id: UInt64 { // bits[0, 64)
            get {
                return storage.value(at: 0)
            }
        }
    }

    var id: UInt64 { // bits[0, 64)
        get {
            return storage.value(at: 0)
        }
    }
    var displayName: String! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }
    var displayNamePrefixLength: UInt32 { // bits[64, 96)
        get {
            return storage.value(at: 64)
        }
    }
    var scopeId: UInt64 { // bits[128, 192)
        get {
            return storage.value(at: 128)
        }
    }
    var parameters: [Parameter]! { // ptr[5]
        get {
            return storage.value(at: 5)
        }
    }
    var isGeneric: Bool { // bits[288, 289)
        get {
            return storage.value(at: 288)
        }
    }
    var nestedNodes: [NestedNode]! { // ptr[1]
        get {
            return storage.value(at: 1)
        }
    }
    var annotations: [Annotation]! { // ptr[2]
        get {
            return storage.value(at: 2)
        }
    }

    var union: Union {
        get {
            return storage.value(at: 96)
        }
    }
}

struct Enumerant: StructInitializable { // 8 bytes, 2 ptrs
    var storage: Struct

    var name: String! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }
    var codeOrder: UInt16 { // bits[0, 16)
        get {
            return storage.value(at: 0)
        }
    }
    var annotations: [Annotation]! { // ptr[1]
        get {
            return storage.value(at: 1)
        }
    }
}

struct Superclass: StructInitializable { // 8 bytes, 1 ptrs
    var storage: Struct

    var id: UInt64 { // bits[0, 64)
        get {
            return storage.value(at: 0)
        }
    }
    var brand: Brand! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }
}

struct Method: StructInitializable { // 24 bytes, 5 ptrs
    var storage: Struct

    var name: String! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }
    var codeOrder: UInt16 { // bits[0, 16)
        get {
            return storage.value(at: 0)
        }
    }
    var implicitParameters: [Node.Parameter]! { // ptr[4]
        get {
            return storage.value(at: 4)
        }
    }
    var paramStructType: UInt64 { // bits[64, 128)
        get {
            return storage.value(at: 64)
        }
    }
    var paramBrand: Brand! { // ptr[2]
        get {
            return storage.value(at: 2)
        }
    }
    var resultStructType: UInt64 { // bits[128, 192)
        get {
            return storage.value(at: 128)
        }
    }
    var resultBrand: Brand! { // ptr[3]
        get {
            return storage.value(at: 3)
        }
    }
    var annotations: [Annotation]! { // ptr[1]
        get {
            return storage.value(at: 1)
        }
    }
}

struct Value: StructInitializable { // 16 bytes, 1 ptrs
    var storage: Struct

    enum Union: UnionProtocol { // tag bits [0, 16)
        case void // bits[0, 0), union tag = 0
        case bool(Bool) // bits[16, 17), union tag = 1
        case int8(Int8) // bits[16, 24), union tag = 2
        case int16(Int16) // bits[16, 32), union tag = 3
        case int32(Int32) // bits[32, 64), union tag = 4
        case int64(Int64) // bits[64, 128), union tag = 5
        case uint8(UInt8) // bits[16, 24), union tag = 6
        case uint16(UInt16) // bits[16, 32), union tag = 7
        case uint32(UInt32) // bits[32, 64), union tag = 8
        case uint64(UInt64) // bits[64, 128), union tag = 9
        case float32(Float32) // bits[32, 64), union tag = 10
        case float64(Float64) // bits[64, 128), union tag = 11
        case text(String!) // ptr[0], union tag = 12
        case data(Data!) // ptr[0], union tag = 13
//        case list(AnyPointer) // ptr[0], union tag = 14
        case `enum`(UInt16) // bits[16, 32), union tag = 15
//        case struct(AnyPointer) // ptr[0], union tag = 16
        case interface // bits[0, 0), union tag = 17
//        case anyPointer(AnyPointer) // ptr[0], union tag = 18

        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 0:
                self = .void
            case 1:
                self = .bool(storage.value(at: 16))
            case 2:
                self = .int8(storage.value(at: 16))
            case 3:
                self = .int16(storage.value(at: 16))
            case 4:
                self = .int32(storage.value(at: 32))
            case 5:
                self = .int64(storage.value(at: 64))
            case 6:
                self = .uint8(storage.value(at: 16))
            case 7:
                self = .uint16(storage.value(at: 16))
            case 8:
                self = .uint32(storage.value(at: 32))
            case 9:
                self = .uint64(storage.value(at: 64))
            case 10:
                self = .float32(storage.value(at: 32))
            case 11:
                self = .float64(storage.value(at: 64))
            case 12:
                self = .text(storage.value(at: 0))
            case 13:
                self = .data(storage.value(at: 0))
            case 14: fatalError()
            case 15:
                self = .enum(storage.value(at: 16))
            case 16: fatalError()
            case 17:
                self = .interface
            case 18: fatalError()

            default: fatalError()
            }
        }
    }

    var union: Union { // tag bits [0, 16)
        get {
            return storage.value(at: 0)
        }
    }
}

struct Annotation: StructInitializable {
    var storage: Struct

    var id: UInt64 { // bits[0, 64)
        get {
            return storage.value(at: 0)
        }
    }
    var brand: Brand! { // ptr[1]
        get {
            return storage.value(at: 1)
        }
    }
    var value: Value! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }

}

struct Brand: StructInitializable { // 0 bytes, 1 ptrs
    var storage: Struct

    var scopes: [Scope]! { // ptr[0]
        get {
            return storage.value(at: 0)
        }
    }

    struct Scope: StructInitializable {  // 16 bytes, 1 ptrs
        var storage: Struct

        var scopeId: UInt64 { // bits[0, 64)
            get {
                return storage.value(at: 0)
            }
        }

        enum Union: UnionProtocol {
            case bind([Binding]!) // ptr[0], union tag = 0
            case inherit // bits[0, 0), union tag = 1

            init(tag: UInt16, storage: Struct) {
                switch tag {
                case 0:
                    self = .bind(storage.value(at: 0))
                case 1:
                    self = .inherit
                default:
                    fatalError()
                }
            }
        }
    }

    struct Binding: StructInitializable { // 8 bytes, 1 ptrs
        var storage: Struct

        enum Union: UnionProtocol { // tag bits [0, 16)
            case unbound // bits[0, 0), union tag = 0
            case type(Type!) // ptr[0], union tag = 1

            init(tag: UInt16, storage: Struct) {
                switch tag {
                case 0:
                    self = .unbound
                case 1:
                    self = .type(storage.value(at: 0))
                default: fatalError()
                }
            }
        }
    }
}

struct Type: StructInitializable {  // 16 bytes, 1 ptrs
    var storage: Struct

    enum Union: UnionProtocol {  // tag bits [0, 16)
        case void // bits[0, 0), union tag = 0
        case bool // bits[0, 0), union tag = 1
        case int8 // bits[0, 0), union tag = 2
        case int16 // bits[0, 0), union tag = 3
        case int32 // bits[0, 0), union tag = 4
        case int64 // bits[0, 0), union tag = 5
        case uint8 // bits[0, 0), union tag = 6
        case uint16 // bits[0, 0), union tag = 7
        case uint32 // bits[0, 0), union tag = 8
        case uint64 // bits[0, 0), union tag = 9
        case float32 // bits[0, 0), union tag = 10
        case float64 // bits[0, 0), union tag = 11
        case text // bits[0, 0), union tag = 12
        case data // bits[0, 0), union tag = 13
        struct List: StructInitializable {
            var storage: Runtime.Struct

            var elementType: Type! { // ptr[0]
                get {
                    return storage.value(at: 0)
                }
            }
        }
        case list(List) // union tag = 14
        struct Enum {
            var storage: Runtime.Struct

            var typeId: UInt64 { // bits[64, 128)
                get {
                    return storage.value(at: 64)
                }
            }
            var brand: Brand! { // ptr[0]
                get {
                    return storage.value(at: 0)
                }
            }
        }
        case `enum`(Enum) // union tag = 15
        struct Struct {
            var storage: Runtime.Struct

            var typeId: UInt64 { // bits[64, 128)
                get {
                    return storage.value(at: 64)
                }
            }
            var brand: Brand! { // ptr[0]
                get {
                    return storage.value(at: 0)
                }
            }
        }
        case `struct`(Struct) // union tag = 16
        struct Interface {
            var storage: Runtime.Struct

            var typeId: UInt64 { // bits[64, 128)
                get {
                    return storage.value(at: 64)
                }
            }
            var brand: Brand! { // ptr[0]
                get {
                    return storage.value(at: 0)
                }
            }
        }
        case interface(Interface) // union tag = 17
        //TODO: implement
//        enum AnyPointer : UnionProtocol {
//            enum Unconstrained : UnionProtocol {
//                case anyKind(Void)
//                case `struct`(Void)
//                case list(Void)
//                case capability(Void)
//                init(tag: UInt16, storage: Struct) {
//                    switch tag {
//                    case 0:
//                        self = .anyKind(storage.value(at: 0))
//                    case 1:
//                        self = .`struct`(storage.value(at: 0))
//                    case 2:
//                        self = .list(storage.value(at: 0))
//                    case 3:
//                        self = .capability(storage.value(at: 0))
//                    default: fatalError()
//                    }
//                }
//            }
//            struct Parameter : StructInitializable {
//                var storage: Runtime.Struct
//                var scopeId: UInt64 {
//                    get {
//                        return storage.value(at: 1)
//                    }
//                }
//                var parameterIndex: UInt16 {
//                    get {
//                        return storage.value(at: 1)
//                    }
//                }
//            }
//            struct ImplicitMethodParameter : StructInitializable {
//                var storage: Runtime.Struct
//                var parameterIndex: UInt16 {
//                    get {
//                        return storage.value(at: 1)
//                    }
//                }
//            }
//            init(tag: UInt16, storage: Struct) {
//                switch tag {
//                    self = .unconstrained(unconstrained(storage: storage))
//                    self = .parameter(parameter(storage: storage))
//                    self = .implicitMethodParameter(implicitMethodParameter(storage: storage))
//                default: fatalError()
//                }
//            }
//        }

//        struct AnyPointer: StructInitializable {
//            var storage: Runtime.Struct
//
//            enum Union: UnionProtocol {
//                enum Unconstrained: UnionProtocol {
//                    enum Union: UnionProtocol {
//                        case anyKind
//                        case struct
//                        case list
//                        case capability
//                    }
//                }
//            }
//        }
//        anyPointer :group {  // union tag = 18
//            union {  // tag bits [32, 48)
//                unconstrained :group {  // union tag = 0
//                    union {  // tag bits [16, 32)
//                        anyKind @18 :Void;  // bits[0, 0), union tag = 0
//                        struct @25 :Void;  // bits[0, 0), union tag = 1
//                        list @26 :Void;  // bits[0, 0), union tag = 2
//                        capability @27 :Void;  // bits[0, 0), union tag = 3
//                    }
//                }
//                parameter :group {  // union tag = 1
//                    scopeId @19 :UInt64;  // bits[64, 128)
//                    parameterIndex @20 :UInt16;  // bits[16, 32)
//                }
//                implicitMethodParameter :group {  // union tag = 2
//                    parameterIndex @24 :UInt16;  // bits[16, 32)
//                }
//            }
//        }

        init(tag: UInt16, storage: Runtime.Struct) {
            switch tag {
            case 0:
                self = .void
            case 1:
                self = .bool
            case 2:
                self = .int8
            case 3:
                self = .int16
            case 4:
                self = .int32
            case 5:
                self = .int64
            case 6:
                self = .uint8
            case 7:
                self = .uint16
            case 8:
                self = .uint32
            case 9:
                self = .uint64
            case 10:
                self = .float32
            case 11:
                self = .float64
            case 12:
                self = .text
            case 13:
                self = .data
            case 14:
                self = .list(Type.Union.List(storage: storage))
            case 15:
                self = .enum(Type.Union.Enum(storage: storage))
            case 16:
                self = .struct(Type.Union.Struct(storage: storage))
            case 17:
                self = .interface(Type.Union.Interface(storage: storage))
            case 18:
//                fatalError("todo")
                self = .void
            default: fatalError()
            }
        }
    }

    var union: Union {
        get {
            return storage.value(at: 0)
        }
    }
}

struct CodeGeneratorRequest: StructInitializable {
    var storage: Struct

    struct RequestedFile: StructInitializable {
        var storage: Struct

        struct Import: StructInitializable {
            var storage: Struct

            var id: UInt64 {
                get {
                    return storage.value(at: 0)
                }
            }
            var name: String! {
                get {
                    return storage.value(at: 0)
                }
            }
        }

        var id: UInt64 {
            get {
                return storage.value(at: 0)
            }
        }
        var filename: String! {
            get {
                return storage.value(at: 0)
            }
        }
        var imports: [Import]! {
            get {
                return storage.value(at: 1)
            }
        }
    }

    var nodes: [Node]! {
        get {
            return storage.value(at: 0)
        }
    }
    var requestedFiles: [RequestedFile]! {
        get {
            return storage.value(at: 1)
        }
    }
}
