//
//  InviteCodeRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import FirebaseFirestore
import Combine

enum InviteCodeRepositoryError: Error {
    case expired
    case fetchError
}

class InviteCodeRepository {
    private let db = Firestore.firestore()
//    private var householdCollectionListener: ListenerRegistration?
//    var household: AnyPublisher<Household, Never> {
//        _household.eraseToAnyPublisher()
//    }
//    private let _household = CurrentValueSubject<Household, Never>(.empty)
    
    init() {}
    
    func createHousehold(from householdObject: Household) {
//        do {
//            try db.collection("households").document(householdObject.id).setData(from: householdObject)
//        } catch let error {
//            print("Error writing household to Firestore: \(error)")
//        }
    }
    
    func readInviteCode(_ inviteCode: String) async throws -> String {
        do {
            let document = try await db.collection("inviteCodes").document(inviteCode).getDocument()
            if let expirationTime = document.data()?["expirationTime"] as? Timestamp,
               let householdId = document.data()?["hoseholdId"] as? String
            {
                let currentTime = Timestamp(date: .now)
                if currentTime.seconds < expirationTime.seconds {
                    LogUtil.log("Invite code is valid")
                    return householdId
                }
                else {
                    LogUtil.log("invite code has expired")
                    throw InviteCodeRepositoryError.expired
                }
            }
            else {
                LogUtil.log("No expiration time")
                throw InviteCodeRepositoryError.fetchError
            }
        }
        catch {
            LogUtil.log("Error getting document: \(error)")
            throw error
        }

    }
    
    func reset() {
        LogUtil.log("resetting")
//        householdCollectionListener?.remove()
//        householdCollectionListener = nil
//        _household.send(.empty)
    }
    
    deinit {
//        householdCollectionListener?.remove()
    }
}
