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
    /// Processes an implant asynchronously. Causes RF.
    public func run(completion: @escaping (VivoAuthResult) -> Void) {
        // Check our challenge hasn't expired/exists
        if(CFAbsoluteTimeGetCurrent() - challts > 25 || challenge == "") {
            let semaphore = DispatchSemaphore(value: 1)
            // It's greater than 25, give ourselves time to do stuff and grab a new one
            DispatchQueue.global().async {
                // Run our challenge, use a semaphore to signal it as completed
                self.api.getChallenge() { response in
                    self.challenge = response
                    self.challts = CFAbsoluteTimeGetCurrent()
                    semaphore.signal()
                }
            }
            // Semaphore means we wait here until the DispatchQueue finishes
            semaphore.wait()
        }
        if (tagtype == VivoTag.SPARK_1) {
            // Spark 1
            // Run a single sign
            var resp: String = ""
            tag!.singleSign(challenge: challenge) {response in
                // grab Resp
                resp = response
                // Build an auth result - basically chain builds to create a checkResp and so on
                self.api.checkResp(vivoResp: VivoResponse(piccChall: self.challenge, piccResp: resp, piccUid: self.tag!.getUid())) {response2 in
                    self.authResult = VivoAuthResult(resp: response2!)
                    completion(self.authResult!)
                }
            }
            return
        }
        if (tagtype == VivoTag.SPARK_2) {
            // Either or, the Tag abstracts Apex/Spark 2 because Apple probes for us
            // Nab the UID
            let chipUid = tag!.getUid()
            var pcdChall:String = ""
            tag!.authPart1() { response in
                pcdChall = response
                var pcdResp:String = ""
                self.api.getPcdResp(pcd: VivoPCD(ChipUid: chipUid, piccChallenge: self.challenge, PcdChallenge: pcdChall)) {response2 in
                    pcdResp = response2
                    self.tag!.authPart2(pcdResp: pcdResp) {piccResp in
                        self.api.checkResp(vivoResp: VivoResponse(piccChall: self.challenge, piccResp: piccResp, piccUid: chipUid)) {response3 in
                            self.authResult = VivoAuthResult(resp: response3!)
                            completion(self.authResult!)
                        }
                        
                    }
                    
                }
                
            }
            return
        }
        
    }
    
    public func getAuth() -> VivoAuthResult {
        return authResult!
    }
}

