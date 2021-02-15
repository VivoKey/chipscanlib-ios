//
//  VivoChallenge.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 6/2/21.
//

import Foundation


public struct VivoChallenge: Encodable {
    // A structure to handle requesting a challenge from the VivoKey API
    let apikey: String
    init(ApiKey api: String) {
        apikey = api
    }
    
}

public struct VivoChallengeResponse: Decodable {
    // A structure to handle a challenge from the VivoKey API for JSON
    let chall: String
    let timeout: Int
    
    
    enum CodingKeys: String, CodingKey {
        case chall = "picc-challenge"
        case timeout = "timeout"
    }
}
