//
//  VivoAuthResult.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 11/2/21.
//

import Foundation

class VivoAuthResult {
    var chipid: String = ""
    var memberid: String = ""
    var membertype: String = ""
    var challenge: String = ""
    
    /// Processes the authentication response received from the API
    init(resp: VivoResponseReturn) {
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
