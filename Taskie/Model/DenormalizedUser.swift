//
//  DenormalizedUser.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Foundation

struct DenormalizedUser: Codable {
    static let empty = DenormalizedUser(id: "", name: nil, profileColor: nil)
    static let mock = DenormalizedUser(
        id: "some id",
        name: "some name", 
        profileColor: "#FDFB67FF"
    )
    
    let id: String
    let name: String?
    let profileColor: String?
    
    init(
        id: String,
        name: String?,
        profileColor: String?
    ) {
        self.id = id
        self.name = name
        self.profileColor = profileColor
    }
}

