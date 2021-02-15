//
//  VivoAuthenticator.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 11/2/21.
//

import Foundation

public class VivoAuthenticator {
    /// Authenticator class, pass it a tag and it'll do the rest.
    
    var tag: VivoTag?
    var api: VivoAPI
    var tagtype: Int = 0
    var authResult: VivoAuthResult?
    var challenge: String = ""
    var challts: Double = 0
    var isError: Bool = false
    var errorCode: Int = 0
    var errorString: String = ""
    let ERROR_TAGLOST = 1
    let ERROR_APIERR = 2
    let ERROR_TAGINVALID = 3
    let ERROR_TAGERR = 4
    
    
    public init(apikey: String) {
        api = VivoAPI(apiKey: apikey)
        
    }
    
    /// Set the VivoTag to the received Tag
    public func setTag(receivedTag: VivoTag) {
        tag = receivedTag
        tagtype = tag!.type
    }
    
    /// Get a challenge asynchronously
    public func getChallenge() {
        // Gets a challenge manually
        api.getChallenge() {response in
            // Once finalised, we set the challenge
            self.challenge = response
            self.challts = CFAbsoluteTimeGetCurrent()
        }
        
    }
    /// Processes an implant synchronously. Causes RF.
    public func run() {
        // Check our challenge hasn't expired/exists
        if(CFAbsoluteTimeGetCurrent() - challts > 25 || challenge == "") {
            // It's greater than 25, give ourselves time to do stuff and grab a new one
                getChallenge()
        }
        if (tagtype == VivoTag.SPARK_1) {
            // Spark 1
            // Run a single sign
            let resp = tag!.singleSign(challenge: challenge)
            // Build an auth result - basically chain builds to create a checkResp and so on
            authResult = VivoAuthResult(resp: api.checkResp(vivoResp: VivoResponse(piccChall: challenge, piccResp: resp, piccUid: tag!.getUid())))
            return
        }
        if (tagtype == VivoTag.SPARK_2) {
            // Either or, the Tag abstracts Apex/Spark 2 because Apple probes for us
            // Nab the UID
            let chipUid = tag!.getUid()
            let pcdChall = tag!.authPart1()
            let pcdResp = api.getPcdResp(pcd: VivoPCD(ChipUid: chipUid, piccChallenge: challenge, PcdChallenge: pcdChall))
            let piccResp = tag!.authPart2(pcdResp: pcdResp)
            authResult = VivoAuthResult(resp: api.checkResp(vivoResp: VivoResponse(piccChall: challenge, piccResp: piccResp, piccUid: chipUid)))
            return
        }
        
        
    }
    
    public func getAuth() -> VivoAuthResult {
        return authResult!
    }
}

