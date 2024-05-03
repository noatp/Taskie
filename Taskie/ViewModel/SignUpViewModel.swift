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
    
    private var authService: AuthService
    private var householdService: HouseholdService
    private var userService: UserService
    private var householdIdFromUniversalLink: String?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authService: AuthService,
        householdService: HouseholdService,
        userService: UserService
        
    ) {
        self.authService = authService
        self.householdService = householdService
        self.userService = userService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.householdIdReceivedFromLink.sink { [weak self] householdId in
            LogUtil.log("From HouseholdService -- householdId -- \(householdId)")
            self?.householdIdFromUniversalLink = householdId
        }
        .store(in: &cancellables)
    }
    
    func signUp() {
        self.authService.signUp(withEmail: email, password: password, name: name)
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
