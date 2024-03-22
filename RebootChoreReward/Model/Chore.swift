//
//  Chore.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import Firebase

struct Chore: Codable {
    static let empty = Chore(id: "", name: "", creator: "", description: "", rewardAmount: 0.0, imageUrls: [], createdDate: .init(date: .now))
    static let mock = Chore(id: "some id", name: "some name", creator: "some id", description: "some description", rewardAmount: 2.00, imageUrls: [], createdDate: .init(date: .now))
    
    let id: String
    let name: String
    let creator: String
    let description: String
    let rewardAmount: Double
    let imageUrls: [String]
    let createdDate: Timestamp
}
