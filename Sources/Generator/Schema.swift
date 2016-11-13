// core object - other files extend it
struct Schema {
    let nodes: [UInt64:Node]
    let trees: [ASTNode]

    init(request: CodeGeneratorRequest) {
        var nodes = [UInt64:Node]()
        for node in request.nodes ?? [] {
            nodes[node.id] = node
        }
        self.nodes = nodes

        // find all children of node, recursively calls `ast(for:named:)`
        func children(of node: Node) -> [ASTNode] {
            var children = [ASTNode]()
            for nestedNode in node.nestedNodes ?? [] {
                guard let node = nodes[nestedNode.id] else {
                    continue
                }
                children.append(ast(for: node, named: nestedNode.name))
            }

            return children
        }

        /// returns the tip of the tree, recurses through `children(of:)`
        func ast(for node: Node, named name: String) -> ASTNode {
            return ASTNode(node: node, children: children(of: node), name: name)
        }

        // finds tips, creates complete trees from there
        func trees() -> [ASTNode] {
            // tip = node without a parent
            // search all the nodes for those without a parent
            let tips: [Node] = nodes.values.filter { node in nodes[node.scopeId] == nil }

            // for each tip, construct the rest of the tree
            return tips.map { tip in ast(for: tip, named: "TIP HAS NO NAME IT IS A fatalError() IF YOU SEE THIS") }
        }

        self.trees = trees()
    }
}
