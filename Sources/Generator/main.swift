import Foundation
import Runtime

// https://github.com/dwrensha/capnpc-rust/blob/master/src/codegen.rs#L1753
func generateCode(from data: Data) throws -> [(fileName: String, contents: String)] {

    let message = Message(data: data)

    let generator = try GeneratorContext(message: message)

    return try generator.request.requestedFiles.map { requestedFile in
        let rootName = "\(requestedFile.filename.ns.lastPathComponent.ns.deletingPathExtension.ns.replacingOccurrences(of: "-", with: "_"))_capnp"

        let lines = FormattedText.branch([
            .line("// Generated by the capnpc-swift plugin to the Cap'n Proto schema compiler."),
            .line("// DO NOT EDIT."),
            .line("// source: \(requestedFile.filename!)"),
            .blankLine,
            try generateNode(generator: generator, nodeId: requestedFile.id, nodeName: rootName)
        ])

        print(lines.stringified)
        return ("\(rootName).swift", lines.stringified)
    }
}

let from = "/Users/dan/Developer/projects/capnpc-swift/Resources/schema.capnpb"
let to = "/Users/dan/Developer/projects/capnpc-swift/Resources"
let inURL = URL(fileURLWithPath: from)
let `in` = try FileHandle(forReadingFrom: inURL)
let data = `in`.readDataToEndOfFile()
for (fileName, contents) in try generateCode(from: data) {
    let path = to.ns.appendingPathComponent(fileName)
    try contents.write(toFile: path, atomically: true, encoding: .utf8)
}
