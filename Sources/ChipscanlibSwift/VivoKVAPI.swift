//
//  VivoKVAPI.swift
//  
//
//  Created by Riley Gall on 17/2/21.
//

import Foundation
import Alamofire

public class VivoKVAPI {
    var challenge: String = ""
    var postSet: VivoKVSetPost?
    var postGet: VivoKVGet?
    let postGetKV = "https://api2.vivokey.com/v1/kvp-read"
    let postSetKV = "https://api2.vivokey.com/v1/kvp-store"
    public init(authres: VivoAuthResult) {
        challenge = authres.challenge
    }
    
    public func setKV(keyvals: [String: String]) {
        postSet = VivoKVSetPost(chall: challenge, kvSet: keyvals)
    }
    
    public func runSetKV(completion: @escaping (String) -> Void) -> Void {
        // Set the KV, return the result or empty string on error
        AF.request(postSetKV, method: .post, parameters: postSet!, encoder: JSONParameterEncoder.default).responseDecodable (of: VivoKVSetResult.self) { response in
            guard let resp = response.value else {
                completion("")
                return
            }
            if(resp.result != "success") {
                completion(resp.result)
            } else {
                completion("success")
            }
            
            
        }
    }
    
    public func getKV(keyvals: [String]) {
        postGet = VivoKVGet(chall: challenge, kvGet: keyvals)
    }
    
    public func runGetKV(completion: @escaping (VivoKVGetResult?) -> Void) -> Void {
        // Get the KV and return a result (or nil on error)
        AF.request(postGetKV, method: .post, parameters: postGet!, encoder: JSONParameterEncoder.default).responseDecodable (of: VivoKVGetResult.self) { response in
            guard let resp = response.value else {
                completion(nil)
                return
            }
            completion(resp)
            
        }
    }
}
