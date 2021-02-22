//
//  apiTest.swift
//  
//
//  Created by Riley Gall on 15/2/21.
//

import XCTest
import CryptoSwift
@testable import ChipscanlibSwift

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
        var resp2: VivoAuthResult?
        vivoApi.checkResp(vivoResp: VivoResponse(piccChall: resp, piccResp: cryptedRev, piccUid: "1e037b01a46d4add")) {response in
            resp2 = response
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp2!.memberId,  "75e95abb37ee6e413ce5431f3785023312093c7fb62deb77dbe4c34a3a108227ae28e61998029c3edbc6393f84e0422315dc4c87e10fe31db4a435790f051579")
        
        
    }
    
    func testShouldSetKV() {
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
        var resp2: VivoAuthResult?
        vivoApi.checkResp(vivoResp: VivoResponse(piccChall: resp, piccResp: cryptedRev, piccUid: "1e037b01a46d4add")) {response in
            resp2 = response
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp2!.memberId,  "75e95abb37ee6e413ce5431f3785023312093c7fb62deb77dbe4c34a3a108227ae28e61998029c3edbc6393f84e0422315dc4c87e10fe31db4a435790f051579")
        // With a valid challenge, we now need to run the setKV
        resp2!.setChall(chall: resp)
        let kvapi = VivoKVAPI(authres: resp2!)
        let kv = ["iosTest": "1234", "iosTest2": "5678"]
        kvapi.setKV(keyvals: kv)
        let expectation3 = self.expectation(description: "Set key-value pair")
        var resp3: String = ""
        kvapi.runSetKV() { response in
            resp3 = response
            expectation3.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp3, "success")
        // Run cleanup
        let kvclear = ["iosTest": "", "iosTest2":""]
        kvapi.setKV(keyvals: kvclear)
        let expectation5 = self.expectation(description: "Clear values")
        var resp5: String = ""
        kvapi.runSetKV() { response in
            resp5 = response
            expectation5.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp5, "success")
        
    }
    
    func testShouldGetKV() {
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
        var resp2: VivoAuthResult?
        vivoApi.checkResp(vivoResp: VivoResponse(piccChall: resp, piccResp: cryptedRev, piccUid: "1e037b01a46d4add")) {response in
            resp2 = response
            expectation2.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp2!.memberId,  "75e95abb37ee6e413ce5431f3785023312093c7fb62deb77dbe4c34a3a108227ae28e61998029c3edbc6393f84e0422315dc4c87e10fe31db4a435790f051579")
        // With a valid challenge, we now need to run the setKV
        resp2!.setChall(chall: resp)
        let kvapi = VivoKVAPI(authres: resp2!)
        let kv = ["iosTest": "1234", "iosTest2": "5678"]
        kvapi.setKV(keyvals: kv)
        let expectation3 = self.expectation(description: "Set key-value pair")
        var resp3: String = ""
        kvapi.runSetKV() { response in
            resp3 = response
            expectation3.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp3, "success")
        // Now validate the get
        let kvget = ["iosTest", "iosTest2"]
        let expectation4 = self.expectation(description: "Get key-value pair")
        kvapi.getKV(keyvals: kvget)
        var resp4: [String: String] = Dictionary()
        kvapi.runGetKV() { response in
            resp4 = response!.data
            expectation4.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp4["iosTest"], "1234")
        XCTAssertEqual(resp4["iosTest2"], "5678")
        // Run cleanup
        let kvclear = ["iosTest": "", "iosTest2":""]
        kvapi.setKV(keyvals: kvclear)
        let expectation5 = self.expectation(description: "Clear values")
        var resp5: String = ""
        kvapi.runSetKV() { response in
            resp5 = response
            expectation5.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(resp5, "success")
    }
    
    

    static var allTests = [
        ("shouldGetChallenge", testShouldGetChallenge),
        ("shouldCheckResponse", testShouldCheckResponse),
        ("shouldSetKV", testShouldSetKV),
        ("shouldGetKV", testShouldGetKV)
        
    ]
}

