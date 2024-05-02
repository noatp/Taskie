//
//  RootViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var hasHouseholdData: Bool = false
    @Published var hasUserData: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    private var authService: AuthService
    private var userService: UserService
    private var householdService: HouseholdService
    private var choreService: ChoreService
    
    init(
        authService: AuthService,
        userService: UserService,
        householdService: HouseholdService,
        choreService: ChoreService
    ) {
        self.authService = authService
        self.userService = userService
        self.householdService = householdService
        self.choreService = choreService
        authService.silentLogIn()
        subscribeToUserService()
        subscribeToAuthService()
        subscribeToHouseholdService()
    }
    
    private func subscribeToAuthService() {
        authService.isUserLoggedIn.sink { [weak self] (isUserLoggedIn, error) in
            LogUtil.log("From AuthService -- (isUserLoggedIn, error) -- \((isUserLoggedIn, error))")
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserService() {
        userService.user.sink { [weak self] (user, error) in
            LogUtil.log("From UserService -- (user, error) -- \((user, error))")
            if let error = error {
                self?.errorMessage = "Error fetching user data from server. Please try again later."
                self?.hasUserData = false
            }
            if let user = user {
                self?.hasUserData = true
            }
            else {
                self?.hasUserData = false
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] (household, error) in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.hasHouseholdData = false
            }
            
            if let household = household {
                self?.hasHouseholdData = true
            }
            else {
                self?.hasHouseholdData = false
            }
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func rootViewModel() -> RootViewModel {
        return RootViewModel(
            authService: service.authService,
            userService: service.userService,
            householdService: service.householdService,
            choreService: service.choreService
        )
    }
}
