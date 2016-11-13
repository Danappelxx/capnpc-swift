struct FarPointer {

    static func decode(pointer: UInt64) -> (isOneWord: Bool, offset: Int, segmentIndex: Int) {
        // A (2 bits) = 2, to indicate that this is a far pointer.
        precondition(pointer.bitRange(0..<2) == 2)

        // B (1 bit) = 0 if the landing pad is one word, 1 if it is two words.
        let isOneWord = pointer.bitRange(2..<3) == 0

        // C (29 bits) = Offset, in words, from the start of the target segment
        // to the location of the far-pointer landing-pad within that
        // segment.  Unsigned.
        let offset = Int(pointer.bitRange(3..<32))

        // D (32 bits) = ID of the target segment. (Segments are numbered
        // sequentially starting from zero.)
        let segmentIndex = Int(pointer.bitRange(32..<64))

        return (isOneWord, offset, segmentIndex)
    }

    static func resolve(scanner: Scanner, in message: Message) -> Pointer? {
        var scanner = scanner

        // the pointer is the first word of the object
        let pointer = scanner.scan(UInt64.self)

        let (isOneWord, offset, segmentIndex) = FarPointer.decode(pointer: pointer)

        var target = message.segments[segmentIndex]
        target.advance(byWords: offset)

        switch isOneWord {
        case true:
            // If B == 0, then the “landing pad” of a far pointer is normally
            // just another pointer, which in turn points to the actual object.
            return Pointer(scanner: target, in: message)

        case false:
            //            // If B == 1, then the “landing pad” is itself another far pointer
            //            let landingPad = target.scan(UInt64.self)
            //            let (isOneWord, offset, segmentIndex) = FarPointer.decode(pointer: landingPad)
            //
            //            // always has B = 0
            //            assert(isOneWord)
            //            // The landing pad is itself immediately followed by a tag word.
            //            let tag = target.scan(UInt64.self)
            //            // The tag word looks exactly like an intra-segment pointer to the target object would look, except that the offset is always zero.
            //            // This far pointer points to the start of the object’s content, located in some other segment. The landing pad is itself immediately followed by a tag word. The tag word looks exactly like an intra-segment pointer to the target object would look, except that the offset is always zero.
            //            var target = message.segments[segmentIndex]

            fatalError("not implemented")
        }
    }
}
