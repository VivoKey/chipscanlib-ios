//
//  VivoAuthResult.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 11/2/21.
//

import Foundation

public class VivoAuthResult: Decodable {
    public var chipId: String = ""
    public var memberId: String = ""
    public var memberType: String = ""
    var challenge: String = ""
    enum CodingKeys: String, CodingKey {
        case memberType = "check-result"
        case resultData = "result-data"
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.memberType = try! container.decode(String.self, forKey: .memberType)
        if(self.memberType == "chip-id") {
            // Chip type
            self.chipId = try container.decode(String.self, forKey: .resultData)
        }
        else if (self.memberType == "member-id") {
            // Member type
            self.memberId = try container.decode(String.self, forKey: .resultData)
            
        } else if (self.memberType == "chip-member") {
            // Our resultData is not valid, so we need to actually decode it as an Array
            var resultArr = try container.nestedUnkeyedContainer(forKey: .resultData)
            self.chipId = try resultArr.decode(String.self)
            self.memberId = try resultArr.decode(String.self)
        }

        
    }
    public func setChall(chall: String) {
        challenge = chall
    }
}
