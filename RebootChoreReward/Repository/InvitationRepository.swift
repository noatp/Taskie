//
//  InvitationRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/2/24.
//

import FirebaseFirestore
import Combine

enum InvitationRepositoryError: Error {
    case fetchingError
}

class InvitationRepository {
    private let db = Firestore.firestore()
    
    func readInvitationForHouseholdId(withEmail email: String) async throws -> String {
        let invitationDocRef = db.collection("invitations").document(email)
        
        let invitationDoc = try await invitationDocRef.getDocument()
        if invitationDoc.exists,
           let invitation = invitationDoc.data(),
           let householdId = invitation["householdId"] as? String
        {
            return householdId
        }
        throw InvitationRepositoryError.fetchingError
    }
}
