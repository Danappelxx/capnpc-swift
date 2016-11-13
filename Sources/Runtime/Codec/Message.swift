public class Message {
    let segments: [Scanner]
    // The first word of the first segment of the message is always a pointer pointing to the message’s root struct.
    lazy var rootStruct: Struct = Struct(scanner: self.segments[0], in: self)

    init(scanner: Scanner) {
        var scanner = scanner

        // (4 bytes) The number of segments, minus one (since there is always at least one segment).
        let numberOfSegments = Int(scanner.scan(UInt32.self) + 1)

        // (N * 4 bytes) The size of each segment, in words.
        let sizes = (0..<numberOfSegments).map { _ in
            return Int(scanner.scan(UInt32.self))
        }

        // (0 or 4 bytes) Padding up to the next word boundary.
        let padding = scanner.current(as: UInt8.self)
        precondition(padding == 0 || padding == 4)
        scanner.advance(by: Int(padding))

        // The content of each segment, in order.
        self.segments = (0..<numberOfSegments).map { i in
            return scanner.scanWords(sizes[i])
        }
    }
}
