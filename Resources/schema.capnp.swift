struct Node : StructInitializable {
    struct Parameter : StructInitializable {
        var storage: Capnpc.Struct
        var name: String {
            get {
                return storage.string(at: 0)
            }
        }
    }
    struct NestedNode : StructInitializable {
        var storage: Capnpc.Struct
        var name: String {
            get {
                return storage.string(at: 0)
            }
        }
        var id: UInt64 {
            get {
                return storage.value(at: 0)
            }
        }
    }
    var storage: Capnpc.Struct
    var id: UInt64 {
        get {
            return storage.value(at: 0)
        }
    }
    var displayName: String {
        get {
            return storage.string(at: 0)
        }
    }
    var displayNamePrefixLength: UInt32 {
        get {
            return storage.value(at: 2)
        }
    }
    var scopeId: UInt64 {
        get {
            return storage.value(at: 2)
        }
    }
    var nestedNodes: [NestedNode] {
        get {
            return storage.list(at: 1)
        }
    }
    var annotations: [Annotation] {
        get {
            return storage.list(at: 2)
        }
    }
    var parameters: [Parameter] {
        get {
            return storage.list(at: 5)
        }
    }
    var isGeneric: Bool {
        get {
            return storage.bool(at: 288)
        }
    }
    enum Union : UnionProtocol {
        case file(Void)
        struct struct : StructInitializable {
            var storage: Capnpc.Struct
            var dataWordCount: UInt16 {
                get {
                    return storage.value(at: 7)
                }
            }
            var pointerCount: UInt16 {
                get {
                    return storage.value(at: 12)
                }
            }
            var preferredListEncoding: ElementSize {
                get {
                    return storage.enum(at: 13)
                }
            }
            var isGroup: Bool {
                get {
                    return storage.bool(at: 224)
                }
            }
            var discriminantCount: UInt16 {
                get {
                    return storage.value(at: 15)
                }
            }
            var discriminantOffset: UInt32 {
                get {
                    return storage.value(at: 8)
                }
            }
            var fields: [Field] {
                get {
                    return storage.list(at: 3)
                }
            }
        }
        struct enum : StructInitializable {
            var storage: Capnpc.Struct
            var enumerants: [Enumerant] {
                get {
                    return storage.list(at: 3)
                }
            }
        }
        struct interface : StructInitializable {
            var storage: Capnpc.Struct
            var methods: [Method] {
                get {
                    return storage.list(at: 3)
                }
            }
            var superclasses: [Superclass] {
                get {
                    return storage.list(at: 4)
                }
            }
        }
        struct const : StructInitializable {
            var storage: Capnpc.Struct
            var type: Type {
                get {
                    return storage.struct(at: 3)
                }
            }
            var value: Value {
                get {
                    return storage.struct(at: 4)
                }
            }
        }
        struct annotation : StructInitializable {
            var storage: Capnpc.Struct
            var type: Type {
                get {
                    return storage.struct(at: 3)
                }
            }
            var targetsFile: Bool {
                get {
                    return storage.bool(at: 112)
                }
            }
            var targetsConst: Bool {
                get {
                    return storage.bool(at: 113)
                }
            }
            var targetsEnum: Bool {
                get {
                    return storage.bool(at: 114)
                }
            }
            var targetsEnumerant: Bool {
                get {
                    return storage.bool(at: 115)
                }
            }
            var targetsStruct: Bool {
                get {
                    return storage.bool(at: 116)
                }
            }
            var targetsField: Bool {
                get {
                    return storage.bool(at: 117)
                }
            }
            var targetsUnion: Bool {
                get {
                    return storage.bool(at: 118)
                }
            }
            var targetsGroup: Bool {
                get {
                    return storage.bool(at: 119)
                }
            }
            var targetsInterface: Bool {
                get {
                    return storage.bool(at: 120)
                }
            }
            var targetsMethod: Bool {
                get {
                    return storage.bool(at: 121)
                }
            }
            var targetsParam: Bool {
                get {
                    return storage.bool(at: 122)
                }
            }
            var targetsAnnotation: Bool {
                get {
                    return storage.bool(at: 123)
                }
            }
        }
        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 8:
                self = .file(storage.value(at: 0))
            case 9:
                self = .struct(struct(storage: storage))
            case 10:
                self = .enum(enum(storage: storage))
            case 11:
                self = .interface(interface(storage: storage))
            case 12:
                self = .const(const(storage: storage))
            case 13:
                self = .annotation(annotation(storage: storage))
            default: fatalError()
            }
        }
    }
}
struct Field : StructInitializable {
    var storage: Capnpc.Struct
    var name: String {
        get {
            return storage.string(at: 0)
        }
    }
    var codeOrder: UInt16 {
        get {
            return storage.value(at: 0)
        }
    }
    var annotations: [Annotation] {
        get {
            return storage.list(at: 1)
        }
    }
    var discriminantValue: UInt16 {
        get {
            return storage.value(at: 1)
        }
    }
    enum ordinal : UnionProtocol {
        case implicit(Void)
        case explicit(UInt16)
        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 0:
                self = .implicit(storage.value(at: 0))
            case 1:
                self = .explicit(storage.value(at: 6))
            default: fatalError()
            }
        }
    }
    enum Union : UnionProtocol {
        struct slot : StructInitializable {
            var storage: Capnpc.Struct
            var offset: UInt32 {
                get {
                    return storage.value(at: 1)
                }
            }
            var type: Type {
                get {
                    return storage.struct(at: 2)
                }
            }
            var defaultValue: Value {
                get {
                    return storage.struct(at: 3)
                }
            }
            var hadExplicitDefault: Bool {
                get {
                    return storage.bool(at: 128)
                }
            }
        }
        struct group : StructInitializable {
            var storage: Capnpc.Struct
            var typeId: UInt64 {
                get {
                    return storage.value(at: 2)
                }
            }
        }
        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 4:
                self = .slot(slot(storage: storage))
            case 5:
                self = .group(group(storage: storage))
            default: fatalError()
            }
        }
    }
}
struct Enumerant : StructInitializable {
    var storage: Capnpc.Struct
    var name: String {
        get {
            return storage.string(at: 0)
        }
    }
    var codeOrder: UInt16 {
        get {
            return storage.value(at: 0)
        }
    }
    var annotations: [Annotation] {
        get {
            return storage.list(at: 1)
        }
    }
}
struct Superclass : StructInitializable {
    var storage: Capnpc.Struct
    var id: UInt64 {
        get {
            return storage.value(at: 0)
        }
    }
    var brand: Brand {
        get {
            return storage.struct(at: 0)
        }
    }
}
struct Method : StructInitializable {
    var storage: Capnpc.Struct
    var name: String {
        get {
            return storage.string(at: 0)
        }
    }
    var codeOrder: UInt16 {
        get {
            return storage.value(at: 0)
        }
    }
    var paramStructType: UInt64 {
        get {
            return storage.value(at: 1)
        }
    }
    var resultStructType: UInt64 {
        get {
            return storage.value(at: 2)
        }
    }
    var annotations: [Annotation] {
        get {
            return storage.list(at: 1)
        }
    }
    var paramBrand: Brand {
        get {
            return storage.struct(at: 2)
        }
    }
    var resultBrand: Brand {
        get {
            return storage.struct(at: 3)
        }
    }
    var implicitParameters: [Parameter] {
        get {
            return storage.list(at: 4)
        }
    }
}
struct Type : StructInitializable {
    var storage: Capnpc.Struct
    enum Union : UnionProtocol {
        case void(Void)
        case bool(Void)
        case int8(Void)
        case int16(Void)
        case int32(Void)
        case int64(Void)
        case uint8(Void)
        case uint16(Void)
        case uint32(Void)
        case uint64(Void)
        case float32(Void)
        case float64(Void)
        case text(Void)
        case data(Void)
        struct list : StructInitializable {
            var storage: Capnpc.Struct
            var elementType: Type {
                get {
                    return storage.struct(at: 0)
                }
            }
        }
        struct enum : StructInitializable {
            var storage: Capnpc.Struct
            var typeId: UInt64 {
                get {
                    return storage.value(at: 1)
                }
            }
            var brand: Brand {
                get {
                    return storage.struct(at: 0)
                }
            }
        }
        struct struct : StructInitializable {
            var storage: Capnpc.Struct
            var typeId: UInt64 {
                get {
                    return storage.value(at: 1)
                }
            }
            var brand: Brand {
                get {
                    return storage.struct(at: 0)
                }
            }
        }
        struct interface : StructInitializable {
            var storage: Capnpc.Struct
            var typeId: UInt64 {
                get {
                    return storage.value(at: 1)
                }
            }
            var brand: Brand {
                get {
                    return storage.struct(at: 0)
                }
            }
        }
        enum anyPointer : UnionProtocol {
            enum unconstrained : UnionProtocol {
                case anyKind(Void)
                case struct(Void)
                case list(Void)
                case capability(Void)
                init(tag: UInt16, storage: Struct) {
                    switch tag {
                    case 0:
                        self = .anyKind(storage.value(at: 0))
                    case 1:
                        self = .struct(storage.value(at: 0))
                    case 2:
                        self = .list(storage.value(at: 0))
                    case 3:
                        self = .capability(storage.value(at: 0))
                    default: fatalError()
                    }
                }
            }
            case unconstrained(unconstrained)
            struct parameter : StructInitializable {
                var storage: Capnpc.Struct
                var scopeId: UInt64 {
                    get {
                        return storage.value(at: 1)
                    }
                }
                var parameterIndex: UInt16 {
                    get {
                        return storage.value(at: 1)
                    }
                }
            }
            case parameter(parameter)
            struct implicitMethodParameter : StructInitializable {
                var storage: Capnpc.Struct
                var parameterIndex: UInt16 {
                    get {
                        return storage.value(at: 1)
                    }
                }
            }
            case implicitMethodParameter(implicitMethodParameter)
            init(tag: UInt16, storage: Struct) {
                switch tag {
                self = .unconstrained(unconstrained(storage: storage))
                self = .parameter(parameter(storage: storage))
                self = .implicitMethodParameter(implicitMethodParameter(storage: storage))
                default: fatalError()
                }
            }
        }
        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 0:
                self = .void(storage.value(at: 0))
            case 1:
                self = .bool(storage.value(at: 0))
            case 2:
                self = .int8(storage.value(at: 0))
            case 3:
                self = .int16(storage.value(at: 0))
            case 4:
                self = .int32(storage.value(at: 0))
            case 5:
                self = .int64(storage.value(at: 0))
            case 6:
                self = .uint8(storage.value(at: 0))
            case 7:
                self = .uint16(storage.value(at: 0))
            case 8:
                self = .uint32(storage.value(at: 0))
            case 9:
                self = .uint64(storage.value(at: 0))
            case 10:
                self = .float32(storage.value(at: 0))
            case 11:
                self = .float64(storage.value(at: 0))
            case 12:
                self = .text(storage.value(at: 0))
            case 13:
                self = .data(storage.value(at: 0))
            case 14:
                self = .list(list(storage: storage))
            case 15:
                self = .enum(enum(storage: storage))
            case 16:
                self = .struct(struct(storage: storage))
            case 17:
                self = .interface(interface(storage: storage))
            case 18:
                self = .anyPointer(anyPointer(storage: storage))
            default: fatalError()
            }
        }
    }
}
struct Brand : StructInitializable {
    struct Scope : StructInitializable {
        var storage: Capnpc.Struct
        var scopeId: UInt64 {
            get {
                return storage.value(at: 0)
            }
        }
        enum Union : UnionProtocol {
            case bind([Binding])
            case inherit(Void)
            init(tag: UInt16, storage: Struct) {
                switch tag {
                case 1:
                    self = .bind(storage.list(at: 0))
                case 2:
                    self = .inherit(storage.value(at: 0))
                default: fatalError()
                }
            }
        }
    }
    struct Binding : StructInitializable {
        var storage: Capnpc.Struct
        enum Union : UnionProtocol {
            case unbound(Void)
            case type(Type)
            init(tag: UInt16, storage: Struct) {
                switch tag {
                case 0:
                    self = .unbound(storage.value(at: 0))
                case 1:
                    self = .type(storage.struct(at: 0))
                default: fatalError()
                }
            }
        }
    }
    var storage: Capnpc.Struct
    var scopes: [Scope] {
        get {
            return storage.list(at: 0)
        }
    }
}
struct Value : StructInitializable {
    var storage: Capnpc.Struct
    enum Union : UnionProtocol {
        case void(Void)
        case bool(Bool)
        case int8(Int8)
        case int16(Int16)
        case int32(Int32)
        case int64(Int64)
        case uint8(UInt8)
        case uint16(UInt16)
        case uint32(UInt32)
        case uint64(UInt64)
        case float32(Float32)
        case float64(Float64)
        case text(String)
        case data(Data)
        case list(Void)
        case enum(UInt16)
        case struct(Void)
        case interface(Void)
        case anyPointer(Void)
        init(tag: UInt16, storage: Struct) {
            switch tag {
            case 0:
                self = .void(storage.value(at: 0))
            case 1:
                self = .bool(storage.bool(at: 16))
            case 2:
                self = .int8(storage.value(at: 2))
            case 3:
                self = .int16(storage.value(at: 1))
            case 4:
                self = .int32(storage.value(at: 1))
            case 5:
                self = .int64(storage.value(at: 1))
            case 6:
                self = .uint8(storage.value(at: 2))
            case 7:
                self = .uint16(storage.value(at: 1))
            case 8:
                self = .uint32(storage.value(at: 1))
            case 9:
                self = .uint64(storage.value(at: 1))
            case 10:
                self = .float32(storage.value(at: 1))
            case 11:
                self = .float64(storage.value(at: 1))
            case 12:
                self = .text(storage.string(at: 0))
            case 13:
                self = .data(storage.data(at: 0))
            case 14:
                self = .list(storage.value(at: 0))
            case 15:
                self = .enum(storage.value(at: 1))
            case 16:
                self = .struct(storage.value(at: 0))
            case 17:
                self = .interface(storage.value(at: 0))
            case 18:
                self = .anyPointer(storage.value(at: 0))
            default: fatalError()
            }
        }
    }
}
struct Annotation : StructInitializable {
    var storage: Capnpc.Struct
    var id: UInt64 {
        get {
            return storage.value(at: 0)
        }
    }
    var value: Value {
        get {
            return storage.struct(at: 0)
        }
    }
    var brand: Brand {
        get {
            return storage.struct(at: 1)
        }
    }
}
enum ElementSize : UInt16 {
    case empty = 0
    case bit = 1
    case byte = 2
    case twoBytes = 3
    case fourBytes = 4
    case eightBytes = 5
    case pointer = 6
    case inlineComposite = 7
}
struct CodeGeneratorRequest : StructInitializable {
    struct RequestedFile : StructInitializable {
        struct Import : StructInitializable {
            var storage: Capnpc.Struct
            var id: UInt64 {
                get {
                    return storage.value(at: 0)
                }
            }
            var name: String {
                get {
                    return storage.string(at: 0)
                }
            }
        }
        var storage: Capnpc.Struct
        var id: UInt64 {
            get {
                return storage.value(at: 0)
            }
        }
        var filename: String {
            get {
                return storage.string(at: 0)
            }
        }
        var imports: [Import] {
            get {
                return storage.list(at: 1)
            }
        }
    }
    var storage: Capnpc.Struct
    var nodes: [Node] {
        get {
            return storage.list(at: 0)
        }
    }
    var requestedFiles: [RequestedFile] {
        get {
            return storage.list(at: 1)
        }
    }
}
