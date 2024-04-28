//
//  User.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

struct User: Codable {
    enum Role: String, Codable {
        case parent = "parent"
        case child = "child"
    }
    
    static let empty = User(
        name: "",
        id: "",
        household: "",
        role: .parent
    )
    static let mock = User(
        name: "some name",
        id: "some id",
        household: "some id",
        role: .parent
    )
    
    let name: String
    let id: String
    let household: String
    let role: Role
}


