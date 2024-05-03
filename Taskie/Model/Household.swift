//
//  Household.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import FirebaseFirestore

struct Household: Codable {
    static let empty = Household(id: "", tag: "")
    static let mock = Household(
        id: "some id",
        tag: "some tag"
    )
    
    let id: String
    let tag: String
    
    init(
        id: String,
        tag: String
    ) {
        self.id = id
        self.tag = tag
    }
}
