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
    var name: String?
    
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
        guard let email = email, let password = password, let name = name else {
            completion("Please enter your name, email, and password.")
            return
        }
        
        Task {
            do {
                try await self.authService.signUp(withEmail: email, password: password)
                guard let currentUserId = self.authService.currentUserId else {
                    completion("Error signing up: could not get user info")
                    return
                }
                let householdId = UUID().uuidString
                self.householdService.createHousehold(from: Household(id: householdId))
                try await self.userService.createUser(
                    from: User(name: name, id: currentUserId, household: householdId, role: .parent),
                    inHousehold: householdId
                )
                completion(nil)
            } catch {
                completion("Error signing up: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        LogUtil.log("deinit")
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
