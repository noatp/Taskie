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
        householdId: "",
        role: .parent
    )
    static let mock = User(
        name: "some name",
        id: "some id",
        householdId: "some id",
        role: .parent
    )
    
    let name: String
    let id: String
    let householdId: String?
    let role: Role
}


