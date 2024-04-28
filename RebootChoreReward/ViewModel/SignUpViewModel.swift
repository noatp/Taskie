//
//  SignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class SignUpViewModel {
    var email: String?
    var password: String?
    var name: String?
    
    private var currentHousehold: Household?
    private var authService: AuthService
    private var householdService: HouseholdService
    private var userService: UserService
    private var cancellable: Set<AnyCancellable> = []
    
    init(
        authService: AuthService,
        householdService: HouseholdService,
        userService: UserService
    ) {
        self.authService = authService
        self.householdService = householdService
        self.userService = userService
        subscribeToHouseholdFirestoreService()
    }
    
    private func subscribeToHouseholdFirestoreService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("Received household \(household)")
            self?.currentHousehold = household
        }
        .store(in: &cancellable)
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
                
//                var householdId = ""
//
//                if let household = currentHousehold {
//                    householdId = household.id
//                }
//                else {
//                    householdId = UUID().uuidString
//                    self.householdService.createHousehold(from: Household(id: householdId))
//                }

//                try await self.userService.createUser(
//                    from: User(name: name, id: currentUserId, household: householdId, role: .parent),
//                    inHousehold: householdId
//                )
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
