//
//  File.swift
//  
//
//  Created by Riley Gall on 17/2/21.
//

import Foundation

public struct VivoKVSetPost: Encodable {
    var challenge: String
    // Basically it's an array of string dicts
    var dict: [[String: String]]
    init(chall: String, kvSet: [String: String]) {
        // Assign chall
        challenge = chall
        // Convert the dict
        dict = Array(repeating: ["": ""], count: kvSet.count)
        dict.reserveCapacity(kvSet.count)
        var i: Int = 0
        for (k, v) in kvSet {
            var temp: [String: String] = Dictionary(minimumCapacity: 2)
            temp["key"] = k
            temp["value"] = v
            dict[i] = temp
            i += 1
        }
        
    }
    enum CodingKeys: String, CodingKey {
        case challenge = "challenge"
        case dict = "dict"
    }
    
}

public struct VivoKVSetResult: Decodable {
    public var result: String
}

public struct VivoKVGet: Encodable {
    var challenge: String
    var dict: [String]
    init(chall: String, kvGet: [String]) {
        dict = kvGet
        challenge = chall
    }
}
public struct VivoKVGetResult: Decodable {
    var result: String
    var data: [String: String]
    public func getResultCode() -> String {
        return result
    }
    public func getKV() -> [String: String] {
        return data
    }
    enum CodingKeys: String, CodingKey {
        case result = "result"
        case data = "data"
    }
}
