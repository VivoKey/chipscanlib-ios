//
//  apiTest.swift
//  
//
//  Created by Riley Gall on 15/2/21.
//

import XCTest
@testable import chipscanlib_swift

final class apiTest: XCTestCase {
    func testShouldGetChallenge() {
        // Get and test the challenges
        let vivoApi = VivoAPI(apiKey: "005add4870eca84aab06e4f5f41c3736eb4f11558e670f11886a91dea472")
        var resp: String = ""
        let expectation = self.expectation(description: "API response")
        vivoApi.getChallenge() { response in
            resp = response
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotEqual(resp, "")
        print(resp)
        XCTAssertNotEqual(resp, "error")
    }

    static var allTests = [
        ("shouldGetChallenge", testShouldGetChallenge),
    ]
}
