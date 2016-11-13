import Foundation
import Runtime

func generateCode(for data: Data) {
    let message = Message(data: data)

    let request: CodeGeneratorRequest = message.root()

    let schema = Schema(request: request)
    print(Array(schema.nodes.keys))
    for ast in schema.trees {
        func p(node: ASTNode) {
            print(node.node.id, node.name)
            for child in node.children {
                p(node: child)
            }
        }
        p(node: ast)
    }
    for ast in schema.trees {
        let renderer = Renderer(schema: schema, node: ast)
        print(renderer.render())
    }
}

let inURL = URL(fileURLWithPath: "/Users/dan/Developer/projects/capnpc-swift/Resources/schema.capnpb")
let `in` = try FileHandle(forReadingFrom: inURL)
let data = `in`.readDataToEndOfFile()
generateCode(for: data)

//try rendered.write(toFile: "/Users/dan/Developer/projects/capnpc-swift/Resources/schema.capnp.swift", atomically: true, encoding: String.Encoding.utf8)
