//
//  VivoResponse.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 6/2/21.
//

import Foundation

public struct VivoResponse: Encodable {
    // Represents a JSON object to send to the check-result API
    let piccChall: String
    let piccResp: String
    let piccUid: String
    
    enum CodingKeys: String, CodingKey {
        case piccChall = "picc-challenge"
        case piccResp = "picc-response"
        case piccUid = "picc-uid"
    }
}

public struct VivoResponseReturn: Decodable {
    var memberType: String
    var resultData: String

    // Represents a response from the check-result API
    enum CodingKeys: String, CodingKey {
        case memberType = "check-result"
        case resultData = "result-data"
    }
    
    
     
    
}

