//
//  ChoreMapper.swift
//  Taskie
//
//  Created by Toan Pham on 5/21/24.
//

import Foundation
import FirebaseFirestoreInternal

class ChoreMapper {
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    func getChoreFrom(_ dto: ChoreDTO) -> Chore? {
        guard let requestor = userDetail(withId: dto.requestorID) else {
            return nil
        }

        let acceptor = userDetail(withId: dto.acceptorID)
        let actionButtonType = determineActionType(
            requestorId: dto.requestorID,
            acceptorId: dto.acceptorID,
            finishedDate: dto.finishedDate
        )
        let choreStatus = determineChoreStatus(
            acceptorId: dto.acceptorID,
            finishedDate: dto.finishedDate
        )
        
        return Chore(
            id: dto.id,
            name: dto.name,
            requestor: requestor,
            acceptor: acceptor,
            description: dto.description,
            rewardAmount: dto.rewardAmount,
            imageUrls: dto.imageUrls,
            createdDate: dto.createdDate.toRelativeString(),
            finishedDate: dto.finishedDate?.toRelativeString(),
            actionButtonType: actionButtonType ?? .nothing,
            choreStatus: choreStatus
        )
    }
    
    func getChoreDTOFrom(_ chore: Chore) -> ChoreDTO? {
        return ChoreDTO(
            id: chore.id,
            name: chore.name,
            requestorID: chore.requestor.id,
            acceptorID: chore.acceptor?.id,
            description: chore.description,
            rewardAmount: chore.rewardAmount,
            imageUrls: chore.imageUrls,
            createdDate: .init(),
            finishedDate: nil
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
    
    private func determineActionType(requestorId: String, acceptorId: String?, finishedDate: Timestamp?) -> Chore.actionButtonType? {
        if finishedDate != nil {
            return .nothing
        }
        else {
            guard let currentUserId = userService.getCurrentUser()?.id else {
                return nil
            }
            
            if currentUserId == requestorId {
                return .withdraw
            }
            else {
                if let acceptorId = acceptorId {
                    if acceptorId == currentUserId {
                        return .finish
                    }
                    else {
                        return .nothing
                    }
                }
                else {
                    return .accept
                }
            }
        }
    }
    
    private func determineChoreStatus(acceptorId: String?, finishedDate: Timestamp?) -> String {
        if let finishedDate = finishedDate {
            return "Finished"
        }
        else if let acceptorId = acceptorId {
            return "Pending"
        }
        else {
            return ""
        }
    }
}
