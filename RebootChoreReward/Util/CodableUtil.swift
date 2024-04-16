//
//  CodableUtil.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/15/24.
//

import Foundation

struct CodableUtil {
    static func dictionaryFromCodable<T: Codable>(_ object: T) throws -> [String: Any]? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
    }
}
