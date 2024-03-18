//
//  SignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class SignUpViewModel {
    var email: String?
    var password: String?
    
    func signUp(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await AuthService.shared.signUp(withEmail: email, password: password)
                guard let uid = AuthService.shared.getCurrentUserCache(key: "uid") else {
                    completion("Error signing up: could not get user info")
                    return
                }
                let householdId = UUID().uuidString
                HouseholdFirestoreService.shared.createHousehold(from: Household(id: householdId, members: [uid]))
                UserFirestoreService.shared.createUser(from: User(name: "", id: uid, household: householdId))
                completion(nil)
            } catch {
                completion("Error signing up: \(error.localizedDescription)")
            }
        }
    }
}
