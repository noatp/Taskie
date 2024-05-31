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
        name: nil,
        id: "",
        householdId: nil,
        role: .parent,
        profileColor: nil, 
        balance: 0.0
    )
    static let mock = User(
        name: "some name",
        id: "some id",
        householdId: "some id",
        role: .parent, 
        profileColor: "ffffff", 
        balance: 2.0
    )
    
    let name: String?
    let id: String
    let householdId: String?
    let role: Role
    let profileColor: String?
    let balance: Float
}


