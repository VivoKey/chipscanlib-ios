//
//  VivoPCD.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 6/2/21.
//

import Foundation

public struct VivoPCD: Encodable {
    // Structure to handle a get-pcdresponse request as JSON
    let uid: String
    let piccChall: String
    let pcdChall: String
    init(chipUid: String, piccChallenge: String, pcdChallenge: String) {
        uid = chipUid
        piccChall = piccChallenge
        pcdChall = pcdChallenge
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "picc-uid"
        case piccChall = "picc-challenge"
        case pcdChall = "pcd-challenge"
    }
    
}

public struct VivoPCDResp: Decodable {
    // A structure to handle a PCDResponse from the VivoKey API for JSON
    let resp: String
    
    
    enum CodingKeys: String, CodingKey {
        case resp = "pcd-response"
    }
}
