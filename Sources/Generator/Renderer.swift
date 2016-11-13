class Renderer {
    //MARK: writer
    var indentation = 0
    var out = ""
    
    func indent(closure: () -> ()) {
        indentation += 4
        closure()
        indentation -= 4
    }
    func write(_ str: String = "") {
        let indent = (0..<indentation).map { _ in " " }.reduce("", +)
        let indented = str.characters.split(separator: "\n").map { String($0) }
            .map { indent + $0 }
            .joined(separator: "\n")
        print(indented, to: &out)
    }
    func block(_ leading: String, indent shouldIndent: Bool = true, closure: () -> ()) {
        write(leading + " {")
        if shouldIndent {
            indent(closure: closure)
        } else {
            closure()
        }
        write("}")
    }
    func write(_ node: ASTNode) {
        write(Renderer(schema: schema, node: node).render())
    }
//    func write(group: Field.Union.Group, in field: Field) {
//        guard let n = nodes[group.typeId] else {
//            fatalError()
//        }
//        write(ASTNode(node: n, name: field.name).render())
//    }

    //MARK: renderer
    let schema: Schema
    let node: ASTNode
    init(schema: Schema, node: ASTNode) {
        self.schema = schema
        self.node = node
    }

    /** For example:
     ```
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
     ```
     */
    func render(enum value: Node.Union.Enum) {
        block("enum \(node.name) : UInt16") {
            for enumerant in value.enumerants {
                write("case \(enumerant.name!) = \(enumerant.codeOrder)")
            }
        }
    }

    /** For example:
     ```
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
     ```
     */
    func render(union value: Node.Union.Struct) {
        block("enum \(node.name) : UnionProtocol") {
            // cases
            for field in value.fields {
                switch field.union {

                // slot = inline type (string, int, void, etc)
                case let .slot(slot):
                    let swiftType = schema.swiftType(for: slot.type)
                    //TODO: handle void case
                    write("case \(field.name!)(\(swiftType))")

                // group = nested (union, struct, etc)
                case let .group(group):
                    guard let groupNode = schema.find(id: group.typeId) else {
                        fatalError()
                    }
                    write(groupNode)
                    //TODO: maybe capitalize? otherwise fails to compile
                    write("case \(field.name!)(\(groupNode.name))")

                }
            }

            // initializer
            block("init(tag: UInt16, storage: Struct)") {
                block("switch tag", indent: false) {
                    // case + self = .case for each field
                    for field in value.fields {
                        switch field.union {

                        case let .slot(slot):
                            //TODO: handle void case
                            write("case \(field.codeOrder):")
                            indent {
                                write("self = .\(field.name!)(\(schema.getter(for: slot)))")
                            }

                        case let .group(group):
                            guard let groupNode = schema.find(id: group.typeId) else {
                                fatalError()
                            }
                            indent {
                                //TODO: what about nested unions (intializers take tag, etc)
                                write("self = .\(field.name!)(\(groupNode.name)(storage: storage))")
                            }

                        }
                    }
                    // TODO: don't fatalError
                    write("default: fatalError()")
                }
            }
        }
    }
    
    /** For example (inside Brand.Scope):
     ```
     enum Union : UnionProtocol {
     case bind([Binding])
     case inherit(Void)
     init(tag: UInt16, storage: Struct) {
     switch tag {
     case 1:
     self = .bind(storage.value(at: 0))
     case 2:
     self = .inherit(storage.value(at: 0))
     default: fatalError()
     }
     }
     }
     ```
     */
    func render(unnamedUnion value: Node.Union.Struct) {
        block("enum Union : UnionProtocol") {
            for field in value.fields where field.insideUnion {
                switch field.union {
                case let .slot(slot):
                    //TODO: handle void case
                    write("case \(field.name!)(\(schema.swiftType(for: slot.type)))")
                case let .group(group):
                    guard let groupNode = schema.find(id: group.typeId) else {
                        //TODO: why is it crashing here?
                        fatalError()
                    }
                    write(groupNode)
                }
            }
            block("init(tag: UInt16, storage: Struct)") {
                block("switch tag", indent: false) {
                    for field in value.fields where field.insideUnion {
                        write("case \(field.codeOrder):")
                        indent {
                            switch field.union {
                            case let .slot(slot):
                                //TODO: handle void case
                                write("self = .\(field.name!)(\(schema.getter(for: slot)))")
                            case let .group(group):
                                guard let groupNode = schema.find(id: group.typeId) else {
                                    fatalError()
                                }
                                write("self = .\(field.name!)(\(groupNode.name)(storage: storage))")
                            }
                        }
                    }
                    // TODO: don't fatalError
                    write("default: fatalError()")
                }
            }
        }
    }
    
    /** For example:
     ```
     struct Annotation : StructInitializable {
     var storage: Runtime.Struct
     var id: UInt64 {
     get {
     return storage.value(at: 0)
     }
     }
     var value: Value {
     get {
     return storage.value(at: 0)
     }
     }
     var brand: Brand {
     get {
     return storage.value(at: 1)
     }
     }
     }
     ```
     */
    func render(struct value: Node.Union.Struct) {
        block("struct \(node.name) : StructInitializable") {
            
            // (recursively) render all children first
            for child in node.children {
                write(child)
            }

            // basic properties
            write("var storage: Runtime.Struct")
            for field in value.fields where !field.insideUnion {
                switch field.union {
                case let .slot(slot):
                    write(schema.signature(for: slot, propertyName: field.name))

                case let .group(group):
                    guard let groupNode = schema.find(id: group.typeId) else {
                        fatalError()
                    }
                    write(groupNode)
                }
            }

            // has an unnamed union
            if value.discriminantCount > 0 {
                render(unnamedUnion: value)
            }
        }
    }

    func render() -> String {
        switch node.node.union {
        case .file:
            for child in node.children {
                write(child)
            }

        case let .enum(value):
            render(enum: value)

        case let .struct(value) where value.discriminantCount > 0 && value.isGroup:
            render(union: value)

        case let .struct(value):
            render(struct: value)

        default: break
        }

        return out
    }
}
