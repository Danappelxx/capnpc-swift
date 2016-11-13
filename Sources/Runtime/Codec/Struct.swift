public struct Struct {

    static func decode(pointer: UInt64) -> (offset: Int, dataSectionSize: Int, pointerSectionSize: Int) {
        // A (2 bits) = 0, to indicate that this is a struct pointer.
        precondition(pointer.bitRange(0..<2) == 0)
        // B (30 bits) = Offset, in words, from the end of the pointer to the
        // start of the struct's data section.  Signed.
        let offset = Int(pointer.bitRange(2..<32))
        // C (16 bits) = Size of the struct's data section, in words.
        let dataSectionSize = Int(pointer.bitRange(32..<48))
        // D (16 bits) = Size of the struct's pointer section, in words.
        let pointerSectionSize = Int(pointer.bitRange(48..<64))

        return (offset, dataSectionSize, pointerSectionSize)
    }

    let data: Scanner
    let pointers: [Pointer?]

    init(data: Scanner, pointers: [Pointer?]) {
        self.data = data
        self.pointers = pointers
    }

    init(scanner: Scanner, in message: Message, dataSectionSize: Int, pointerSectionSize: Int) {
        var scanner = scanner

        // The content is split into two sections: data and pointers, with
        // the pointer section appearing immediately after the data section.
        self.data = scanner.scanWords(dataSectionSize)

        var pointerSection = scanner.scanWords(pointerSectionSize)
        // contigous list of UInt64 values (pointers)
        self.pointers = (0..<pointerSection.wordSize).map { i in
            defer { pointerSection.advance(by: MemoryLayout<UInt64>.size) }
            return Pointer(scanner: pointerSection, in: message)
        }

    }

    init(scanner: Scanner, in message: Message) {
        var scanner = scanner

        // the pointer is the first word of the object
        let pointer = scanner.scan(UInt64.self)

        let (offset, dataSectionSize, pointerSectionSize) = Struct.decode(pointer: pointer)

        scanner.advance(byWords: offset)

        self.init(scanner: scanner, in: message, dataSectionSize: dataSectionSize, pointerSectionSize: pointerSectionSize)
    }
}

//extension Struct: CustomStringConvertible {
//    var description: String {
//        return "Struct"
//    }
//}
