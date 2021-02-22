//
//  VivoAuthResult.swift
//  chipscanlib-ios
//
//  Created by Riley Gall on 11/2/21.
//

import Foundation

public class VivoAuthResult: Decodable {
    public var chipid: String = ""
    public var memberid: String = ""
    public var membertype: String = ""
    var challenge: String = ""
    enum CodingKeys: String, CodingKey {
        case membertype = "check-result"
        case resultData = "result-data"
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.membertype = try! container.decode(String.self, forKey: .membertype)
        if(self.membertype == "chip-id") {
            // Chip type
            self.chipid = try container.decode(String.self, forKey: .resultData)
        }
        else if (self.membertype == "member-id") {
            // Member type
            self.memberid = try container.decode(String.self, forKey: .resultData)
            
        } else if (self.membertype == "chip-member") {
            // Our resultData is not valid, so we need to actually decode it as an Array
            var resultArr = try container.nestedUnkeyedContainer(forKey: .resultData)
            self.chipid = try resultArr.decode(String.self)
            self.memberid = try resultArr.decode(String.self)
        }

        
    }
    public func setChall(chall: String) {
        challenge = chall
    }
}
