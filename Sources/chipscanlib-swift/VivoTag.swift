//
//  VivoTag.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 26/1/21.
//

import Foundation
import CoreNFC

@available(iOS 14.0, *)
public class VivoTag {
    var isotag: NFCISO7816Tag?
    var tag15: NFCISO15693Tag?
    var type: Int
    var uid: String = ""
    var part1APDU: NFCISO7816APDU?
    var part2APDU: NFCISO7816APDU?
    var selAPDU: NFCISO7816APDU?
    var flags15: NFCISO15693RequestFlag?
    var auth15: Data?
    var subtype: Int?
    
    public static let SPARK_1 = 15
    public static let SPARK_2 = 14
    public static let NTAG4XX = 1
    public static let APEX = 2
    // We have two constructors to build a ISO15693 or ISO14443 VivoTag, respectively
    public init(tag: NFCISO7816Tag, sub: Int) {
        isotag = tag
        type = VivoTag.SPARK_2
        subtype = sub
        if(subtype == VivoTag.NTAG4XX) {
            // NDEF
            part1APDU = NFCISO7816APDU(instructionClass: 0x90, instructionCode: 0x71, p1Parameter: 0x00, p2Parameter: 0x00, data: Data([0x02, 0x02, 0x00]), expectedResponseLength: 16)
            uid = tag.identifier.hexEncodedString()
            print("Tag ID: ", uid)
            
        } else {
            // Apex
            // Assume it's selected already, but we do need the UID
            part1APDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA9, p1Parameter: 0xA3, p2Parameter: 0x00, data: Data(), expectedResponseLength: 128)
            selAPDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA4, p1Parameter: 0x04, p2Parameter: 0x00, data: Data([0x0B, 0xA0, 0x00, 0x00, 0x07, 0x47, 0x00, 0xCC, 0x68, 0xE8, 0x8C, 0x01]), expectedResponseLength: 128)
            
            isotag!.sendCommand(apdu: selAPDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    self.uid = ""
                    return
                }
                // No error
                self.uid = data.hexEncodedString()
            }
        }
        
    }
    @available(iOS 14.0, *)
    public init(tag: NFCISO15693Tag) {
        tag15 = tag
        type = VivoTag.SPARK_1
        flags15 = NFCISO15693RequestFlag.address
        auth15 = Data.init([0x00, 0x02])
        uid = Data(tag15!.identifier.reversed()).hexEncodedString()
        
    }
    public func getUid() -> String {
        return uid
    }
    public func singleSign(challenge: String, completion: @escaping (String) -> Void) -> Void {
        // Runs a single sign against a type 15 chip
        if (type != VivoTag.SPARK_1) {
            completion("")
        }
        // Apple makes this stuff pretty simple, to be honest
        // Use addressed mode
        tag15!.authenticate(requestFlags: flags15!, cryptoSuiteIdentifier: 0, message: auth15!) {response in
            let resp = try! response.get()
            let respFlag = resp.0
            var respData = resp.1
            if (respFlag.contains(NFCISO15693ResponseFlag.error)) {
                // Got an error flag on the response
                completion("")
            } else {
                respData.removeFirst()
                let respStr = respData.hexEncodedString()
                completion(respStr)
            }
        }
        
    }
    
    public func authPart1(completion: @escaping (String) -> Void) -> Void {
        // Gets a PCD challenge from a type 14 chip
        if(type != VivoTag.SPARK_2) {
            print("Not spark 2")
            completion("")
        }
        var respStr: String = ""
        if(subtype == VivoTag.NTAG4XX) {
            // NTAG
            // Send the command and get the response
            isotag!.sendCommand(apdu: part1APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x91 || sw2 != 0xAF) {
                    // Error received
                    respStr = ""
                    print("Pcd chall get error, sw1: ", sw1, "sw2: ", sw2)
                    completion(respStr)
                    return
                }
                // No error
                respStr = data.hexEncodedString()
                completion(respStr)
            }
            
        } else {
            // Apex
            // Do as above, i guess
            isotag!.sendCommand(apdu: part1APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    completion(respStr)
                    return
                }
                // No error
                respStr = data.hexEncodedString()
                completion(respStr)
            }
            
        }
        
    }
    
    public func authPart2(pcdResp: String, completion: @escaping (String) -> Void) -> Void {
        if(type != VivoTag.SPARK_2) {
            completion("")
        }
        var respStr: String = ""
        if(subtype == VivoTag.NTAG4XX) {
            // NTAG
            part2APDU = NFCISO7816APDU(instructionClass: 0x90, instructionCode: 0xAF, p1Parameter: 0x00, p2Parameter: 0x00, data: VivoTag.dataWithHexString(hex: "20"+pcdResp), expectedResponseLength: 32)
            // Actually send
            isotag!.sendCommand(apdu: part2APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x91 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    completion(respStr)
                    return
                }
                // No error
                respStr = data.hexEncodedString()
                completion(respStr)
            }
        } else {
            // Apex
            // Composite response, decompose it
            let fullResp = VivoTag.dataWithHexString(hex: pcdResp)
            let issuerResp = fullResp.subdata(in: 16..<fullResp.endIndex)
            let challResp = fullResp.subdata(in: 0..<16)
            let issuerAPDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA1, p1Parameter: 0x00, p2Parameter: 0x00, data: issuerResp, expectedResponseLength: 128)
            part2APDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA3, p1Parameter: 0x00, p2Parameter: 0x00, data: challResp, expectedResponseLength: 128)
            // Validate the issuer
            isotag!.sendCommand(apdu: issuerAPDU) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    completion(respStr)
                    return
                }
                
                // No error
                // Now send the validator
                self.isotag!.sendCommand(apdu: self.part2APDU!) {data, sw1, sw2, error in
                    if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                        // Error received
                        respStr = ""
                        completion(respStr)
                        return
                    }
                    // No error
                    respStr = data.hexEncodedString()
                    completion(respStr)
                }
            }

        }
    }
    
    public static func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
}
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let utf8Digits = Array(hexDigits.utf8)
            return String(unsafeUninitializedCapacity: 2 * count) { (ptr) -> Int in
                var p = ptr.baseAddress!
                for byte in self {
                    p[0] = utf8Digits[Int(byte / 16)]
                    p[1] = utf8Digits[Int(byte % 16)]
                    p += 2
                }
                return 2 * count
            }
        } else {
            let utf16Digits = Array(hexDigits.utf16)
            var chars: [unichar] = []
            chars.reserveCapacity(2 * count)
            for byte in self {
                chars.append(utf16Digits[Int(byte / 16)])
                chars.append(utf16Digits[Int(byte % 16)])
            }
            return String(utf16CodeUnits: chars, count: chars.count)
        }
    }
}

