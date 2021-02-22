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
    var challts: CFAbsoluteTime = 0
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
        if(challts.distance(to: CFAbsoluteTimeGetCurrent()) > 25.00 || challenge == "") {
            let semaphore = DispatchSemaphore(value: 1)
            print("Waiting for challenge renewal")
            // It's greater than 25, give ourselves time to do stuff and grab a new one
            DispatchQueue.global().async {
                // Run our challenge, use a semaphore to signal it as completed
                self.api.getChallenge() { response in
                    self.challenge = response
                    self.challts = CFAbsoluteTimeGetCurrent()
                    print("Challenge renewed")
                    semaphore.signal()
                }
            }
            // Semaphore means we wait here until the DispatchQueue finishes
            print("Waiting at semaphore")
            semaphore.wait()
            print("Finished waiting at semaphore")
        }
        if (tagtype == VivoTag.SPARK_1) {
            // Spark 1
            // Run a single sign
            var resp: String = ""
            tag!.singleSign(challenge: challenge) {response in
                // grab Resp
                resp = response
                print("response:", resp)
                // Build an auth result - basically chain builds to create a checkResp and so on
                self.api.checkResp(vivoResp: VivoResponse(piccChall: self.challenge, piccResp: resp, piccUid: self.tag!.getUid())) {response2 in
                    self.authResult = VivoAuthResult(resp: response2!, chall: self.challenge)
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
                print("PCD Chall: ", pcdChall)
                var pcdResp:String = ""
                self.api.getPcdResp(pcd: VivoPCD(ChipUid: chipUid, piccChallenge: self.challenge, PcdChallenge: pcdChall)) {response2 in
                    pcdResp = response2
                    
                    self.tag!.authPart2(pcdResp: pcdResp) {piccResp in
                        print("PICC response: ", piccResp)
                        self.api.checkResp(vivoResp: VivoResponse(piccChall: self.challenge, piccResp: piccResp, piccUid: chipUid)) {response3 in
                            self.authResult = VivoAuthResult(resp: response3!, chall: self.challenge)
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

