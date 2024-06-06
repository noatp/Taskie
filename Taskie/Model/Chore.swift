//
//  Chore.swift
//  Taskie
//
//  Created by Toan Pham on 5/23/24.
//

import Foundation

struct Chore {
    enum ActionButtonType {
        case accept
        case finish
        case withdraw
        case nothing
    }
    
    static let empty: Chore = .init(
        id: "",
        name: "",
        requestor: .empty,
        acceptor: nil,
        description: "",
        rewardAmount: 0.0,
        imageUrls: [],
        createdDate: "",
        finishedDate: nil,
        actionButtonType: .accept,
        choreStatus: "Pending"
    )
    
    let id: String
    let name: String
    let requestor: DenormalizedUser
    let acceptor: DenormalizedUser?
    let description: String
    let rewardAmount: Double
    let imageUrls: [String]
    let createdDate: String
    let finishedDate: String?
    let actionButtonType: ActionButtonType
    let choreStatus: String
}
