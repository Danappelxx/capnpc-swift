struct List {

    static func decode(pointer: UInt64) -> (offset: Int, elementSize: Int, elementCount: Int) {
        // A (2 bits) = 1, to indicate that this is a list pointer.
        precondition(pointer.bitRange(0..<2) == 1)

        // B (30 bits) = Offset, in words, from the end of the pointer to the
        // start of the first element of the list. Signed.
        let offset = Int(pointer.bitRange(2..<32))

        // C (3 bits) = Size of each element
        let elementSize = Int(pointer.bitRange(32..<35))

        // D (29 bits) = Number of elements in the list, except when C is 7 (see below).
        let elementCount = Int(pointer.bitRange(35..<64))

        return (offset, elementSize, elementCount)
    }

    enum Size: Int {
        // 0 = 0 (e.g. List(Void))
        case zero = 0
        // 1 = 1 bit
        case bit1
        // 2 = 1 byte
        case byte1
        // 3 = 2 bytes
        case byte2
        // 4 = 4 bytes
        case byte4
        // 5 = 8 bytes (non-pointer)
        case byte8
        // 6 = 8 bytes (pointer)
        case pointer // 8 bytes
        // 7 = composite (see below)
        case composite
    }

    let elementSize: Size
    let elements: [Struct]

    init(scanner: Scanner, in message: Message) {
        var scanner = scanner

        // the pointer is the first word of the object
        let pointer = scanner.scan(UInt64.self)

        let (offset, elementSize, elementCount) = List.decode(pointer: pointer)

        scanner.advance(byWords: offset)

        var elementSection = scanner.scanWords(offset)

        self.elementSize = Size(rawValue: elementSize)!

        func scanStruct(byteCount: Int) -> Struct {
            return Struct(data: elementSection.scanBytes(byteCount), pointers: [])
        }

        switch self.elementSize {
        case .zero:
            self.elements = (0..<elementCount).map { _ in scanStruct(byteCount: 0) }
        case .byte1:
            self.elements = (0..<elementCount).map { _ in scanStruct(byteCount: 1) }
        case .byte2:
            self.elements = (0..<elementCount).map { _ in scanStruct(byteCount: 2) }
        case .byte4:
            self.elements = (0..<elementCount).map { _ in scanStruct(byteCount: 4) }
        case .byte8:
            self.elements = (0..<elementCount).map { _ in scanStruct(byteCount: 4) }
        case .pointer:
            self.elements = (0..<elementCount).map { _ in Struct(data: elementSection.scanBytes(0), pointers: [Pointer(scanner: elementSection.scanBytes(8), in: message)]) }
        case .bit1:
            var bits = [Int]()
            var chunk: UInt64 = elementSection.scan()
            var progress = 0 // out of eight (bytes)

            for _ in 0..<elementCount {
                progress += 1

                let bit = Int(chunk.bitRange(progress-1..<progress))
                bits.append(bit)

                if progress == 8 {
                    progress = 0
                    chunk = elementSection.scan()
                }
            }

            fatalError("bit by bit is not yet implemented")

        case .composite:
            // the list content is prefixed by a “tag” word that describes each
            // individual element. The tag has the same layout as a struct pointer
            let pointer = elementSection.scan(UInt64.self)

            // section (D) of the list pointer – which normally would
            // store this element count – instead stores the total number
            // of words in the list (not counting the tag word).
            let wordCount = elementCount

            // the pointer offset (B) in the struct pointer instead
            // indicates the number of elements in the list.
            let (elementCount, dataSectionSize, pointerSectionSize) = Struct.decode(pointer: pointer)

            if elementCount > 0 {
                assert(wordCount / elementCount == dataSectionSize + pointerSectionSize)
            }

            self.elements = (0..<elementCount).map { _ in
                defer { elementSection.advance(byWords: dataSectionSize + pointerSectionSize) }
                return Struct(scanner: elementSection, in: message, dataSectionSize: dataSectionSize, pointerSectionSize: pointerSectionSize)
            }
        }
    }
}
