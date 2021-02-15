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
    var part1APDU: NFCISO7816APDU?
    var part2APDU: NFCISO7816APDU?
    var selAPDU: NFCISO7816APDU?
    var flags15: NFCISO15693RequestFlag?
    var auth15: Data?
    var subtype: Int?
    
    static let SPARK_1 = 15
    static let SPARK_2 = 14
    static let NTAG4XX = 1
    static let APEX = 2
    // We have two constructors to build a ISO15693 or ISO14443 VivoTag, respectively
    public init(tag: NFCISO7816Tag, sub: Int) {
        isotag = tag
        type = 14
        subtype = sub
        if(subtype == VivoTag.NTAG4XX) {
            // NDEF
            part1APDU = NFCISO7816APDU(instructionClass: 0x90, instructionCode: 0x71, p1Parameter: 0x00, p2Parameter: 0x00, data: Data([0x00, 0x00]), expectedResponseLength: 0)
            
        } else {
            // Apex
            // Assume it's selected already, but we do need the UID
            part1APDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA9, p1Parameter: 0xA3, p2Parameter: 0x00, data: Data(), expectedResponseLength: 0)
            selAPDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA4, p1Parameter: 0x04, p2Parameter: 0x00, data: Data([0xA0, 0x00, 0x00, 0x07, 0x47, 0x00, 0xCC, 0x68, 0xE8, 0x8C, 0x01]), expectedResponseLength: 0)
            
        }
        
    }
    @available(iOS 14.0, *)
    public init(tag: NFCISO15693Tag) {
        tag15 = tag
        type = VivoTag.SPARK_1
        flags15 = NFCISO15693RequestFlag.address
        auth15 = Data.init([0x00, 0x02])
        
    }
    public func getUid() -> String {
        if (type == VivoTag.SPARK_1) {
            // 15693
            // Reverse the UID and return
            return Data(tag15!.identifier.reversed()).hexEncodedString()
        } else if (type == VivoTag.SPARK_2 && subtype == VivoTag.NTAG4XX) {
            // NDEF
            return isotag!.identifier.hexEncodedString()
        } else if (type == VivoTag.SPARK_2 && subtype == VivoTag.APEX) {
            // Apex
            var respStr: String = ""
            isotag!.sendCommand(apdu: selAPDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x91 || sw2 != 0xAF) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                respStr = data.hexEncodedString()
            }
            return respStr
            
        }
        else {
            // Not supported
            return ""
        }
    }
    public func singleSign(challenge: String) -> String {
        // Runs a single sign against a type 15 chip
        if (type != VivoTag.SPARK_1) {
            return ""
        }
        var respFlag: NFCISO15693ResponseFlag?
        var respData: Data?
        // Apple makes this stuff pretty simple, to be honest
        // Use addressed mode
        tag15!.authenticate(requestFlags: flags15!, cryptoSuiteIdentifier: 0, message: auth15!) {response in
            let resp = try! response.get()
            respFlag = resp.0
            respData = resp.1
        }
        if (respFlag!.contains(NFCISO15693ResponseFlag.error)) {
            // Got an error flag on the response
            return ""
        }
        // Success, decode that data array
        // Pop the first off, as it's a Barker flag
        respData!.removeFirst()
        let respStr = respData!.hexEncodedString()
        return respStr
        
        
        
    }
    
    public func authPart1() -> String {
        // Gets a PCD challenge from a type 14 chip
        if(type != VivoTag.SPARK_2) {
            return ""
        }
        var respStr: String = ""
        if(subtype == VivoTag.NTAG4XX) {
            // NTAG
            // Send the command and get the response
            isotag!.sendCommand(apdu: part1APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x91 || sw2 != 0xAF) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                respStr = data.hexEncodedString()
            }
            return respStr
        } else {
            // Apex
            // Do as above, i guess
            isotag!.sendCommand(apdu: part1APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                respStr = data.hexEncodedString()
            }
            return respStr
            
        }
        
    }
    
    public func authPart2(pcdResp: String) -> String {
        if(type != VivoTag.SPARK_2) {
            return ""
        }
        var respStr: String = ""
        if(subtype == VivoTag.NTAG4XX) {
            // NTAG
            part2APDU = NFCISO7816APDU(instructionClass: 0x90, instructionCode: 0xAF, p1Parameter: 000, p2Parameter: 0x00, data: VivoTag.dataWithHexString(hex: pcdResp), expectedResponseLength: 0)
            // Actually send
            isotag!.sendCommand(apdu: part2APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x91 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                respStr = data.hexEncodedString()
            }
            return respStr
        } else {
            // Apex
            // Composite response, decompose it
            let fullResp = VivoTag.dataWithHexString(hex: pcdResp)
            let issuerResp = fullResp.subdata(in: 16..<fullResp.endIndex)
            let challResp = fullResp.subdata(in: 0..<16)
            let issuerAPDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA1, p1Parameter: 0x00, p2Parameter: 0x00, data: issuerResp, expectedResponseLength: 0)
            part2APDU = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xA3, p1Parameter: 0x00, p2Parameter: 0x00, data: challResp, expectedResponseLength: 0)
            // Validate the issuer
            isotag!.sendCommand(apdu: issuerAPDU) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                
            }
            // Now send the validator
            isotag!.sendCommand(apdu: part2APDU!) {data, sw1, sw2, error in
                if(nil != error || sw1 != 0x90 || sw2 != 0x00) {
                    // Error received
                    respStr = ""
                    return
                }
                // No error
                respStr = data.hexEncodedString()
            }
            return respStr
            
        }
    }
    
    static func dataWithHexString(hex: String) -> Data {
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

