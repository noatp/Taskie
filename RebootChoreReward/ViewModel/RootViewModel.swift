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
        subscribeToChoreService()
    }
    
    private func subscribeToAuthService() {
        authService.error.sink { [weak self] error in
            LogUtil.log("From AuthService -- error -- \(error)")
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserService() {
        userService.user.sink { [weak self] user in
            LogUtil.log("From UserService -- user -- \(user)")
            if let user = user {
                self?.hasUserData = true
            }
            else {
                self?.hasUserData = false
            }
        }
        .store(in: &cancellables)
        
        userService.error.sink { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] household in
            if let household = household {
                self?.hasHouseholdData = true
            }
            else {
                self?.hasHouseholdData = false
            }
        }
        .store(in: &cancellables)
        
        householdService.error.sink { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToChoreService() {
        choreService.error.sink { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
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
