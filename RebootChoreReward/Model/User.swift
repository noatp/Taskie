//
//  User.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

struct User: Codable {
    static let empty = User(name: "", id: "", household: "")
    static let mock = User(
        name: "some name",
        id: "some id",
        household: "some id"
    )
    
    let name: String
    let id: String
    let household: String
}
