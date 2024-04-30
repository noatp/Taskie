//
//  Household.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import FirebaseFirestore

struct Household: Codable {
    static let empty = Household(id: "")
    static let mock = Household(
        id: "some id"
    )
    
    let id: String
    
    init(
        id: String
    ) {
        self.id = id
    }
}
