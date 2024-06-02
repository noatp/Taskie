//
//  Convo.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import FirebaseFirestoreInternal

struct ChatMessage: Codable {
    static let empty = ChatMessage(id: "some id", message: "", senderId: "", imageUrls: [], sendDate: .init())
    
    static let mock = ChatMessage(id: "some id", message: "this is a message", senderId: "some id", imageUrls: [], sendDate: .init())
    let id: String
    let message: String
    let senderId: String
    let imageUrls: [String]?
    let sendDate: Timestamp
}
