//
//  ChatMessageMapper.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Foundation
import FirebaseFirestoreInternal

class ChatMessageMapper {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func getChatMessageFrom(_ dto: ChatMessageDTO) -> ChatMessage? {
        guard let sender = userDetail(withId: dto.senderId),
              let currentUserId = userService.getCurrentUser()?.id
        else {
            return nil
        }
        
        return ChatMessage(
            id: dto.id,
            message: dto.message,
            sender: sender,
            isFromCurrentUser: sender.id == currentUserId,
            imageUrls: dto.imageUrls,
            sendDate: dto.sendDate.toRelativeString(),
            type: dto.type
        )
    }
    
    func getChatMessageDTOFrom(_ chatMessage: ChatMessage) -> ChatMessageDTO? {
        return ChatMessageDTO(
            id: chatMessage.id,
            message: chatMessage.message,
            senderId: chatMessage.sender.id,
            imageUrls: chatMessage.imageUrls,
            sendDate: Timestamp(),
            type: chatMessage.type
        )
    }
    
    private func userDetail(withId lookUpId: String?) -> DenormalizedUser? {
        guard let lookUpId = lookUpId,
              let currentUserId = userService.getCurrentUser()?.id
        else {
            return nil
        }
        var userDetail: DenormalizedUser? = nil
        
        if let familyMember = userService.readFamilyMember(withId: lookUpId) {
            if lookUpId == currentUserId {
                userDetail = .init(id: familyMember.id, name: "You", profileColor: familyMember.profileColor)
            }
            else {
                userDetail = familyMember
            }
        }
        
        return userDetail
    }
}
