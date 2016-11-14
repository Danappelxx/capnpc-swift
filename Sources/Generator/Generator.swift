import Foundation
import Runtime

extension String {
    var ns: NSString {
        return NSString(string: self)
    }
}

enum GeneratorError : Error {
    case nodeNotFound(nodeId: UInt64)
    case scopeNotFound(nodeId: UInt64)
}

//WARNING: copied nearly line by line from capnpc-rust (MIT)
class GeneratorContext {
    let request: CodeGeneratorRequest
    let nodeMap: [UInt64: Node]
    let scopeMap: [UInt64: [String]]

    // https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L38
    init(message: Message) throws {
        self.request = message.root()
        var nodeMap = [UInt64: Node]()
        var scopeMap = [UInt64: [String]]()

        for node in request.nodes {
            nodeMap[node.id] = node
        }

        for requestedFile in request.requestedFiles {

            for `import` in requestedFile.imports {
                //TODO: ensure this is correct
                //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L55
                let importName = `import`.name.ns.lastPathComponent.ns.deletingPathExtension.ns.replacingOccurrences(of: "-", with: "_")
                let importMod = "::\(importName)_capnp"
                try populateScopeMap(
                    nodeMap: &nodeMap,
                    scopeMap: &scopeMap,
                    scopeNames: [importMod],
                    nodeId: `import`.id
                )
            }

            let rootName = requestedFile.filename.ns.lastPathComponent.ns.deletingPathExtension.ns.replacingOccurrences(of: "-", with: "_")
            let rootMod = "::\(rootName)_capnp"
            try populateScopeMap(
                nodeMap: &nodeMap,
                scopeMap: &scopeMap,
                scopeNames: [rootMod],
                nodeId: requestedFile.id
            )
        }

        self.nodeMap = nodeMap
        self.scopeMap = scopeMap
    }
}

// https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L143
indirect enum FormattedText {
    case indent(FormattedText)
    case branch([FormattedText])
    case line(String)
    case blankLine

    func toLines(indent: Int) -> [String] {
        switch self {
        case let .indent(ft):
            return ft.toLines(indent: indent + 1)
        case let .branch(fts):
            return fts
                .map { ft in ft.toLines(indent: indent) }
                .flatMap { $0 }
        case let .line(line):
            let indentation = (0..<indent*2).map { _ in " " }.joined(separator: "")
            return [indentation + line]
        case .blankLine:
            return [""]
        }
    }

    var stringified: String {
        return toLines(indent: 0).joined(separator: "\n") + "\n"
    }
}


// https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L200
func populateScopeMap(nodeMap: inout [UInt64: Node], scopeMap: inout [UInt64: [String]], scopeNames: [String], nodeId: UInt64) throws {
    scopeMap[nodeId] = scopeNames

    guard let node = nodeMap[nodeId] else {
        throw GeneratorError.nodeNotFound(nodeId: nodeId)
    }

    //TODO: ensure this is correct
    for nestedNode in node.nestedNodes ?? [] {
        var scopeNames = scopeNames
        guard let node = nodeMap[nestedNode.id] else {
            continue
        }
        switch node.union {
        case .enum:
            scopeNames.append(nestedNode.name)
        default:
            scopeNames.append(moduleName(for: nestedNode.name))
        }
        try populateScopeMap(nodeMap: &nodeMap, scopeMap: &scopeMap, scopeNames: scopeNames, nodeId: nestedNode.id)
    }

    if case let .struct(`struct`) = node.union {
        for field in `struct`.fields {
            guard case let .group(group) = field.union else {
                continue
            }
            try populateScopeMap(
                nodeMap: &nodeMap,
                scopeMap: &scopeMap,
                scopeNames: scopeNames + [moduleName(for: field.name)],
                nodeId: group.typeId
            )
        }
    }
}

//TODO: complete list
let swiftKeywords = ["struct"]

func moduleName(for string: String) -> String {
    return swiftKeywords.contains(string)
        ? string + "_"
        : string
}

//https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L296
//TODO: add isReader parameter
func getterText(generator: GeneratorContext, field: Field) throws -> String {
    switch field.union {

    case let .group(group):
        fatalError()

    case let .slot(regField):
        fatalError()

    }
}

//https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L973
//TODO: add parentNodeId
func generateNode(generator: GeneratorContext, nodeId: UInt64, nodeName: String) throws -> FormattedText {
    var output = [FormattedText]()
    var nestedOutput = [FormattedText]()

    guard let node = generator.nodeMap[nodeId] else {
        throw GeneratorError.nodeNotFound(nodeId: nodeId)
    }

    for nestedNode in node.nestedNodes {
        guard let nodeName = generator.scopeMap[nestedNode.id]?.last else {
            throw GeneratorError.scopeNotFound(nodeId: nestedNode.id)
        }
        try nestedOutput.append(generateNode(generator: generator, nodeId: nestedNode.id, nodeName: nodeName))
    }

    switch node.union {

    case .file:
        output.append(.branch(nestedOutput))

    case let .struct(`struct`):
        //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L998
        //TODO: support generics
        //TODO: support pipelines

        var unionFields = [Field]()

        let dataSize = `struct`.dataWordCount
        let pointerSize = `struct`.pointerCount
        let discriminantCount = `struct`.discriminantCount
        let discriminantOffset = `struct`.discriminantOffset

        output.append(.line("public struct \(nodeName) {"))

        output.append(.line("internal var storage: Storage"))

        for field in `struct`.fields ?? [] {
            let name = field.name

            let discriminantValue = field.discriminantValue
            let isUnionField = discriminantValue != Field.noDiscriminant

            switch isUnionField {
            case true:
                unionFields.append(field)
            case false:
                try print(getterText(generator: generator, field: field))
            }
        }

        break

    case let .enum(`enum`):
        //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L1333

        break

    case let .interface(interface):
        //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L1386

        break

    case let .const(const):
        //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L1690

        break

    case let .annotation(annocation):
        //https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L1734

        break

    }

    return .branch(output)
}





