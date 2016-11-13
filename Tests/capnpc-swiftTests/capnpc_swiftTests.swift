import XCTest
@testable import capnpc_swift

class capnpc_swiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(capnpc_swift().text, "Hello, World!")
    }


    static var allTests : [(String, (capnpc_swiftTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
