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
    private var authService: AuthService
    private var householdService: HouseholdService
    private var userService: UserService
    
    init(
        authService: AuthService,
        householdService: HouseholdService,
        userService: UserService
    ) {
        self.authService = authService
        self.householdService = householdService
        self.userService = userService
    }
    
    func signUp(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await authService.signUp(withEmail: email, password: password)
                guard let uid = authService.getCurrentUserCache(key: "uid") else {
                    completion("Error signing up: could not get user info")
                    return
                }
                let householdId = UUID().uuidString
                householdService.createHousehold(from: Household(id: householdId, members: [uid]))
                userService.createUser(from: User(name: "", id: uid, household: householdId, role: .parent))
                completion(nil)
            } catch {
                completion("Error signing up: \(error.localizedDescription)")
            }
        }
    }
}

extension Dependency.ViewModel {
    func signUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(
            authService: service.authService,
            householdService: service.householdService,
            userService: service.userService
        )
    }
}
