//
//  DecentrailizedUser.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Foundation

struct DecentrailizedUser: Codable {
    static let empty = DecentrailizedUser(id: "", name: "")
    static let mock = DecentrailizedUser(
        id: "some id",
        name: "some name"
    )
    
    let id: String
    let name: String
    
    init(
        id: String,
        name: String
    ) {
        self.id = id
        self.name = name
    }
}

