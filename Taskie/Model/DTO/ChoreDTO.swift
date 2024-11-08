//
//  Chore.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestoreInternal

struct ChoreDTO: Codable {
    static let empty = ChoreDTO(
        id: "",
        name: "",
        requestorID: "", 
        acceptorID: nil,
        description: "",
        rewardAmount: 0.0,
        imageUrls: [], 
        isReadyForReview: false,
        createdDate: .init(date: .now),
        finishedDate: nil
    )
    
    static let mock = ChoreDTO(
        id: "some id",
        name: "This is a chore with a long long long long long long long name",
        requestorID: "some id",
        acceptorID: "some other id",
        description: "This is a chore. It is a chore that need to be done. Please do it. You will be rewarded greatly. It is a chore that need to be done. Please do it. You will be rewarded greatly. It is a chore that need to be done. Please do it. You will be rewarded greatly.",
        rewardAmount: 2.00,
        imageUrls: ["https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fvector%2Fthumbnail-image-vector-graphic-gm1147544807-309589937&psig=AOvVaw3UvtbnqxN9ccX88jFYAgvQ&ust=1712642759035000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCOCb-8z5sYUDFQAAAAAdAAAAABAE"],
        isReadyForReview: false,
        createdDate: .init(date: .now),
        finishedDate: .init(date: .now)
    )
    
    let id: String
    let name: String
    let requestorID: String
    let acceptorID: String?
    let description: String
    let rewardAmount: Float
    let imageUrls: [String]
    let isReadyForReview: Bool
    let createdDate: Timestamp
    let finishedDate: Timestamp?
}
