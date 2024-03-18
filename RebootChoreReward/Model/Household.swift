//
//  Household.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

struct Household: Codable {
    static let empty = Household(id: "", members: [])
    static let mock = Household(
        id: "some id",
        members: ["some id", "some id"]
    )
    
    let id: String
    let members: [String] //uid of members
}

