//
//  VivoAPI.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 26/1/21.
//

import Foundation
import Alamofire
public class VivoAPI {
    let session = URLSession.shared
    var apikey = ""
    let postGetChall = "https://api2.vivokey.com/v1/get-challenge"
    let postPcdChall = "https://api2.vivokey.com/v1/pcd-challenge"
    let postCheckResp = "https://api2.vivokey.com/v1/check-response"
    public init(apiKey api: String) {
        // Initialises the API object with an API key
        apikey = api
    }
    
    public func getChallenge(completion: @escaping (String) -> Void) -> Void {
        // Pulls a challenge from the API synchronously, returns it as a byte string
        // Generate the params
        var resp: String = ""
        var finished = false
        AF.request(postGetChall, method: .post, parameters: VivoChallenge(apiKey: apikey), encoder: JSONParameterEncoder.default).responseDecodable (of: VivoChallengeResponse.self) { response in
            print(response)
            guard let jsonResp = response.value else {
                resp = "error"
                finished = true
                completion(resp)
                return
                
            }
            resp = jsonResp.chall
            completion(resp)
            finished = true
            
        }


        
    }
    
    
    
    
    public func getPcdResp(pcd: VivoPCD) -> String {
        // Pull the PCD Response from the API, return as a byte string
        var resp: String = ""
        AF.request(postPcdChall, method: .post, parameters: pcd, encoder: JSONParameterEncoder.default).responseDecodable(of: VivoPCDResp.self) { response in
            guard let jsonResp = response.value else { return }
            resp = jsonResp.resp
        }
        return resp
    }
    
    public func checkResp(vivoResp: VivoResponse) -> VivoResponseReturn {
        // Pull the responses
        var resp: VivoResponseReturn?
        AF.request(postCheckResp, method: .post, parameters: vivoResp, encoder: JSONParameterEncoder.default).responseDecodable(of: VivoResponseReturn.self) { response in
            guard let jsonResp = response.value else { return }
            resp = jsonResp
        }
        return resp!
    }
    
    
    
}

