//
//  VivoAuthResult.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 11/2/21.
//

import Foundation

public class VivoAuthResult {
    public var chipid: String = ""
    public var memberid: String = ""
    public var membertype: String = ""
    var challenge: String = ""
    
    /// Processes the authentication response received from the API
    public init(resp: VivoResponseReturn, chall: String) {
        challenge = chall
        if(resp.memberType == "member-id") {
            memberid = resp.resultData
            membertype = "member"
        } else if (resp.memberType == "chip-id") {
            chipid = resp.resultData
            membertype = "chip"
        } else if (resp.memberType == "chip-member") {
            let arr = try! JSONSerialization.jsonObject(with: VivoTag.dataWithHexString(hex: resp.resultData) , options: []) as! [String]
            chipid = arr[0]
            memberid = arr[1]
            membertype = "chip-member"
        }
    }
}
