extension Schema {
    func swiftType(for type: Type) -> String {
        switch type.union {
        case .void:
            return "Void"
        case .int8:
            return "Int8"
        case .int16:
            return "Int16"
        case .int32:
            return "Int32"
        case .int64:
            return "Int64"
        case .uint8:
            return "UInt8"
        case .uint16:
            return "UInt16"
        case .uint32:
            return "UInt32"
        case .uint64:
            return "UInt64"
        case .float32:
            return "Float32"
        case .float64:
            return "Float64"
        case .bool:
            return "Bool"
        case .text:
            return "String"
        case .data:
            return "Data"

        case let .enum(value):
            // TODO: fix this up
            guard let node = find(id: value.typeId) else {
                //TODO: likely going to hit this fatalerror.
                // use schema's node map instead of ast for this
                fatalError()
            }
            return node.name

        case let .struct(value):
            // TODO: fix this up
            guard let node = find(id: value.typeId) else {
                //TODO: likely going to hit this fatalerror.
                // use schema's node map instead of ast for this
                fatalError()
            }
            return node.name

        case let .list(list):
            return "[\(swiftType(for: list.elementType))]"

        case .interface:
            //TODO: support interfaces
            fatalError("interfaces not yet supported")
        }
    }

    func getter(for slot: Field.Union.Slot) -> String {
        //TODO: what about groups? (dont have anything inside (at:). should it be ignored at the runtime level?
        return "storage.\(swiftType(for: slot.type))(at: \(slot.offset))"
    }

    func signature(for slot: Field.Union.Slot, propertyName: String) -> String {
        return [
            "var \(propertyName): \(swiftType(for: slot.type)) {",
            "    get {",
            "        return \(getter(for: slot))",
            "    }",
            "}"
        ].joined(separator: "\n")
    }
}

extension Field {
    var insideUnion: Bool {
        return discriminantValue != noDiscriminant
    }
}
