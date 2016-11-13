//
//  BitRange.swift
//  BinaryTest
//
//  Created by Jonathan Wight on 6/24/15.
//
//  Copyright © 2016, Jonathan Wight
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

private extension MemoryLayout {
    static var bitSize: Int {
        return size * 8
    }
}

func binary(_ value:UInt64, padding:Int = 0, prefix:String = "") -> String {
    var s = ""
    var bits = 0
    if value == 0 {
        s = "0"
        bits = 1
    } else {
        var n:UInt64 = value
        bits = Int(ceil(log2(Double(n))))
        var index = bits - 1
        while index >= 0 {
            defer { index -= 1 }
            let mask = UInt64(1) << UInt64(index)
            let bit = n & mask != 0
            s += bit ? "1" : "0"
        }
    }
    if padding != 0 {
        let pad = "".padding(toLength: max(padding - bits, 0), withPad:"0", startingAt:0)
        s = pad + s
    }
    return prefix + s
}

// MARK: UnsignedIntegerTypes bitRanges

extension UnsignedInteger {
    func bitRange(start: Int, length: Int, flipped: Bool = false) -> Self {
        assert(MemoryLayout<Self>.size <= MemoryLayout<UIntMax>.size)
        let bitSize = UIntMax(MemoryLayout<Self>.size * 8)
        assert(start + length <= Int(bitSize))
        if flipped {
            let shift = bitSize - UIntMax(start) - UIntMax(length)
            let mask = (1 << UIntMax(length)) - 1
            let intermediate = self.toUIntMax() >> shift & mask
            let result = intermediate
            return Self.init(result)
        }
        else {
            let shift = UIntMax(start)
            let mask = (1 << UIntMax(length)) - 1
            let result = self.toUIntMax() >> shift & mask
            return Self.init(result)
        }
    }

    func bitRange(_ range: Range<Int>, flipped: Bool = false) -> Self {
        return bitRange(start: range.lowerBound, length: range.upperBound - range.lowerBound, flipped: flipped)
    }
}

// MARK: UnsafeBufferPointer bitRanges

func bitRange <Element>(_ buffer: UnsafeBufferPointer <Element>, start: Int, length: Int) -> UIntMax {

    let pointer = UnsafeRawPointer(buffer.baseAddress)!

    // TODO: Swift3 - clean this up in the same manner (or better) we did bitSet (below)
    // Fast path; we want whole integers and the range is aligned to integer size.
    if length == 64 && start % 64 == 0 {
        return pointer.assumingMemoryBound(to: UInt64.self)[start / MemoryLayout <UInt64>.bitSize]
    }
    else if length == 32 && start % 32 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt32.self)[start / MemoryLayout <UInt32>.bitSize])
    }
    else if length == 16 && start % 16 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt16.self)[start / MemoryLayout <UInt16>.bitSize])
    }
    else if length == 8 && start % 8 == 0 {
        return UIntMax(pointer.assumingMemoryBound(to: UInt8.self)[start / MemoryLayout <UInt8>.bitSize])
    }
    else {
        // Slow(er) path. Range is not aligned.
        let pointer = pointer.assumingMemoryBound(to: UIntMax.self)
        let wordSize = MemoryLayout<UIntMax>.size * 8

        let end = start + length

        if start / wordSize == (end - 1) / wordSize {
            // Bit range does not cross two words
            let offset = start / wordSize
            let result = pointer[offset].bigEndian.bitRange(start: start % wordSize, length: length, flipped: true)
            return result
        }
        else {
            // Bit range spans two words, get bit ranges for both words and then combine them.
            let offset = start / wordSize
            let offsettedStart = start % wordSize
            let msw = pointer[offset].bigEndian.bitRange(offsettedStart ..< wordSize, flipped: true)
            let bits = (end - offset * wordSize) % wordSize
            let lsw = pointer[offset + 1].bigEndian.bitRange(0 ..< bits, flipped: true)
            return msw << UIntMax(bits) | lsw
        }
    }
}

func bitRange <Element>(_ buffer: UnsafeBufferPointer <Element>, range: Range <Int>) -> UIntMax {
    return bitRange(buffer, start: range.lowerBound, length: range.upperBound - range.lowerBound)
}

// MARK: UnsignedIntegerType bitSets

func bitSet <T: UnsignedInteger> (_ value: T, start: Int, length: Int, flipped: Bool = false, newValue: T) -> T {
    assert(start + length <= MemoryLayout<T>.size * 8)
    let mask: T = onesMask(start: start, length: length, flipped: flipped)
    let shift = UIntMax(flipped == false ? start: (MemoryLayout<T>.size * 8 - start - length))
    let shiftedNewValue = newValue.toUIntMax() << UIntMax(shift)
    let result = (value.toUIntMax() & ~mask.toUIntMax()) | (shiftedNewValue & mask.toUIntMax())
    return T(result)
}

func bitSet <T: UnsignedInteger> (_ value: T, range: Range <Int>, flipped: Bool = false, newValue: T) -> T {
    return bitSet(value, start: range.lowerBound, length: range.upperBound - range.lowerBound, flipped: flipped, newValue: newValue)
}

// MARK: UnsafeMutableBufferPointer bitSets

func bitSet <Element>(_ buffer: UnsafeMutableBufferPointer <Element>, start: Int, length: Int, newValue: UIntMax) {
    // TODO: Swift3 - why does return an optional?
    let pointer = UnsafeMutableRawPointer(buffer.baseAddress)!

    func set <T: UnsignedInteger> (pointer: UnsafeMutableRawPointer, type: T.Type, newValue: UIntMax) {
        pointer.assumingMemoryBound(to: T.self)[start / (MemoryLayout <T>.bitSize)] = T(newValue)
    }

    // Fast path; we want whole integers and the range is aligned to integer size.
    if length == 64 && start % 64 == 0 {
        set(pointer: pointer, type: UInt64.self, newValue: newValue)
    }
    else if length == 32 && start % 32 == 0 {
        set(pointer: pointer, type: UInt32.self, newValue: newValue)
    }
    else if length == 16 && start % 16 == 0 {
        set(pointer: pointer, type: UInt16.self, newValue: newValue)
    }
    else if length == 8 && start % 8 == 0 {
        set(pointer: pointer, type: UInt8.self, newValue: newValue)
    }
    else {
        // Slow(er) path. Range is not aligned.
        let pointer = pointer.assumingMemoryBound(to: UIntMax.self)
        let wordSize = MemoryLayout<UIntMax>.size * 8

        let end = start + length

        if start / wordSize == (end - 1) / wordSize {
            // Bit range does not cross two words

            let offset = start / wordSize
            let value = pointer[offset].bigEndian
            let result = UIntMax(bigEndian: bitSet(value, start: start % wordSize, length: length, flipped: true, newValue: newValue))
            pointer[offset] = result
        }
        else {
            // Bit range spans two words, get bit ranges for both words and then combine them.
            // unimplemented
            preconditionFailure()
        }
    }
}

func bitSet <Element>(_ buffer: UnsafeMutableBufferPointer <Element>, range: Range <Int>, newValue: UIntMax) {
    bitSet(buffer, start: range.lowerBound, length: range.upperBound - range.lowerBound, newValue: newValue)
}

// MARK: -

private func onesMask <T: UnsignedInteger> (start: Int, length: Int, flipped: Bool = false) -> T {
    let size = UIntMax(MemoryLayout<T>.size * 8)
    let start = UIntMax(start)
    let length = UIntMax(length)
    let shift = flipped == false ? start: (size - start - length)
    let mask = ((1 << length) - 1) << shift
    return T(mask)
}
