import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(chipscanlib_swiftTests.allTests),
        testCase(apiTest.allTests),
    ]
}
#endif
