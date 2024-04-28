//
//  InviteCodeFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import FirebaseFirestore
import Combine
import FirebaseFunctions
import FirebaseAuth

protocol InviteCodeService {
    func readInviteCode(_ inviteCode: String) async throws
}

class InviteCodeFirestoreService: InviteCodeService {
    private var inviteCodeRepository: InviteCodeFirestoreRepository
    private var householdRepository: HouseholdFirestoreRepository
    
    init(
        inviteCodeRepository: InviteCodeFirestoreRepository,
        householdRepository: HouseholdFirestoreRepository
    ) {
        self.inviteCodeRepository = inviteCodeRepository
        self.householdRepository = householdRepository
    }
    
    func readInviteCode(_ inviteCode: String) async throws {
        do {
            let householdId = try await inviteCodeRepository.readInviteCode(inviteCode)
            householdRepository.readHousehold(withId: householdId)
        }
        catch {
            throw error
        }
    }
    
//    func requestInviteCode(completion: @escaping (Bool) -> Void) {
//        let functions = Functions.functions()
//        let householdId = userRepository.currentHouseholdId()
//        guard !householdId.isEmpty else {
//            return
//        }
//        functions.httpsCallable("generateInviteCode").call(["householdId": householdId]) { result, error in
//            if let error = error {
//                LogUtil.log("\(error.localizedDescription)")
//                completion(false)
//            } else if let data = result?.data as? [String: Any], let success = data["success"] as? Bool {
//                completion(success)
//            } else {
//                completion(false)
//            }
//        }
//    }
}

class InviteCodeMockService: InviteCodeService {
    func readInviteCode(_ inviteCode: String) async throws {}
}
