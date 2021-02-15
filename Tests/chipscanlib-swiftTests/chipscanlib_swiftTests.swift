import XCTest
@testable import chipscanlib_swift

final class chipscanlib_swiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(chipscanlib_swift().text, "Hello, World!")
    }
    

    static var allTests = [
        ("testExample", testExample),
    ]
}
