//
//  ChatMessage.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import FirebaseFirestoreInternal

struct ChatMessage: Identifiable, Codable {
    static let empty = ChatMessage(
        id: "",
        message: "",
        sender: .init(id: "", name: "", profileColor: ""),
        isFromCurrentUser: false,
        imageUrls: [],
        sendDate: "",
        type: .normal,
        isFirstInSequence: true,
        isLastInSequence: true
    )
    
    static let mock = ChatMessage(
        id: "some id",
        message: "This is a very very long message",
        sender: .init(id: "some id", name: "some name", profileColor: "#FF00FF"),
        isFromCurrentUser: false,
        imageUrls: [],
        sendDate: "0 seconds ago",
        type: .normal,
        isFirstInSequence: true,
        isLastInSequence: true
    )
    
    let id: String
    let message: String
    let sender: DenormalizedUser
    let isFromCurrentUser: Bool
    let imageUrls: [String]
    let sendDate: String
    let type: MessageType
    var isFirstInSequence: Bool
    var isLastInSequence: Bool
}
