//
//  Household.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

struct Household: Codable {
    static let empty = Household(id: "")
    static let mock = Household(
        id: "some id", inviteCode: "123456"
    )
    
    let id: String
    let inviteCode: String?
    
    init(id: String, inviteCode: String? = nil) {
        self.id = id
        self.inviteCode = inviteCode
    }
}

