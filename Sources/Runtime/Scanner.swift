import Foundation

struct Scanner {
    let start: UnsafeRawPointer
    let end: UnsafeRawPointer
    var current: UnsafeRawPointer

    init(start: UnsafeRawPointer, end: UnsafeRawPointer, current: UnsafeRawPointer? = nil) {
        self.start = start
        self.end = end
        self.current = current ?? start
    }

    init(data: NSData) {
        self.start = data.bytes
        self.end = start + data.length
        self.current = start
    }

    var size: Int {
        return end - start
    }
    var wordSize: Int {
        return size / 8
    }

    var offset: Int {
        return current - start
    }

    func current<T>(as _: T.Type = T.self) -> T {
        return current.bindMemory(to: T.self, capacity: 1).pointee
    }

    func value<T>(atByte offset: Int) -> T {
        return (start.advanced(by: offset)).bindMemory(to: T.self, capacity: 1).pointee
    }
    func value<T>(atBit offset: Int) -> T {
        return value(atByte: offset / 8)
    }

    mutating func advance(by n: Int = 1) {
        current += n
    }

    mutating func advance(byWords n: Int) {
        advance(by: n * 8)
    }

    mutating func scanBytes(_ n: Int) -> Scanner {
        let start = current
        advance(by: n)
        let end = current
        return Scanner(start: start, end: end)
    }

    mutating func scanWords(_ n: Int) -> Scanner {
        // word is 8 bytes
        return scanBytes(n * 8)
    }

    mutating func scan<T>(_: T.Type = T.self) -> T {
        defer { advance(by: MemoryLayout<T>.size) }
        return current.bindMemory(to: T.self, capacity: 1).pointee
    }
}
