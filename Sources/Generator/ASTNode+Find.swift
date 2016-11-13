extension Schema {
    func find(id: UInt64) -> ASTNode? {
        return trees.find(id: id)
    }
}

extension ASTNode {
    func find(id: UInt64) -> ASTNode? {
        if self.node.id == id {
            return self
        }
        return children.find(id: id)
    }
}

extension Sequence where Iterator.Element == ASTNode {
    func find(id: UInt64) -> ASTNode? {
        for node in self {
            if let found = node.find(id: id) {
                return found
            }
        }
        return nil
    }
}
