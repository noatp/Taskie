//
//  Chore.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import Firebase

struct Chore: Codable {
    static let empty = Chore(id: "", name: "", creator: "", description: "", rewardAmount: 0.0, imageUrls: [], createdDate: .init(date: .now))
    static let mock = Chore(id: "some id", name: "some name", creator: "some id", description: "some description", rewardAmount: 2.00, imageUrls: ["https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fvector%2Fthumbnail-image-vector-graphic-gm1147544807-309589937&psig=AOvVaw3UvtbnqxN9ccX88jFYAgvQ&ust=1712642759035000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCOCb-8z5sYUDFQAAAAAdAAAAABAE"], createdDate: .init(date: .now))
    
    let id: String
    let name: String
    let creator: String
    let description: String
    let rewardAmount: Double
    let imageUrls: [String]
    let createdDate: Timestamp
}
