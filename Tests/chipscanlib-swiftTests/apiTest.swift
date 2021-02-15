//
//  apiTest.swift
//  
//
//  Created by Riley Gall on 15/2/21.
//

import XCTest
import CryptoSwift
@testable import chipscanlib_swift

final class apiTest: XCTestCase {
    func testShouldGetChallenge() {
        // Get and test the challenges
        let vivoApi = VivoAPI(apiKey: "005add4870eca84aab06e4f5f41c3736eb4f11558e670f11886a91dea472")
        var resp: String = ""
        let expectation = self.expectation(description: "Challenge response")
        vivoApi.getChallenge() { response in
            resp = response
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotEqual(resp, "")
        XCTAssertNotEqual(resp, "error")
    }
    
    func testShouldCheckResponse() {
        // Get and test a very basic Spark 1 emulation
        let vivoApi = VivoAPI(apiKey: "005add4870eca84aab06e4f5f41c3736eb4f11558e670f11886a91dea472")
        var resp: String = ""
        let expectation = self.expectation(description: "API response")
        vivoApi.getChallenge() { response in
            resp = response
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotEqual(resp, "")
        XCTAssertNotEqual(resp, "error")
        // Convert the string to data, but reverse it at the same time
        let challData = Data(VivoTag.dataWithHexString(hex: resp).reversed())
        // Build a cryptor
        let aes = try! AES(key: [0xC2, 0x7C, 0x2F, 0x68, 0x3B, 0x97, 0x02, 0x09, 0xCF, 0x10, 0x1C, 0xFE, 0xC4, 0x62, 0xBD, 0x76], blockMode: ECB(), padding: .noPadding)
        // Actually encrypt
        let cryptedData = try! aes.encrypt(challData.bytes)
        // Reverse and make string
        let cryptedRev: String = Data(cryptedData.reversed()).hexEncodedString()
        let expectation2 = self.expectation(description: "Check response")
        var resp2: VivoResponseReturn?
        vivoApi.checkResp(vivoResp: VivoResponse(piccChall: resp, piccResp: cryptedRev, piccUid: "1e037b01a46d4add")) {response in
            resp2 = response
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp2!.resultData,  "75e95abb37ee6e413ce5431f3785023312093c7fb62deb77dbe4c34a3a108227ae28e61998029c3edbc6393f84e0422315dc4c87e10fe31db4a435790f051579")
        
        
    }
    
    

    static var allTests = [
        ("shouldGetChallenge", testShouldGetChallenge),
        ("shouldCheckResponse", testShouldCheckResponse),
        
    ]
}

