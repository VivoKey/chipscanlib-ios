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
    let piccchall: String
    let pcdchall: String
    init(chipuid: String, piccchallenge: String, pcdchallenge: String) {
        uid = chipuid
        piccchall = piccchallenge
        pcdchall = pcdchallenge
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "picc-uid"
        case piccchall = "picc-challenge"
        case pcdchall = "pcd-challenge"
    }
    
}

public struct VivoPCDResp: Decodable {
    // A structure to handle a PCDResponse from the VivoKey API for JSON
    let resp: String
    
    
    enum CodingKeys: String, CodingKey {
        case resp = "pcd-response"
    }
}
