//
//  RootViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var hasHouseholdData: Bool?
    @Published var hasUserData: Bool?
    @Published var hasUserName: Bool?
    @Published var hasProfileColor: Bool?
    @Published var errorMessage: String?
    
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
        subscribeToAuthService()
        subscribeToUserService()
        subscribeToHouseholdService()
        subscribeToChoreService()
//        authService.silentLogIn()
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
        userService.user
            .sink { [weak self] user in
            LogUtil.log("From UserService -- user -- \(user)")
            if let user = user {
                self?.hasUserData = true
                
                if let userName = user.name {
                    self?.hasUserName = true
                }
                else {
                    self?.hasUserName = false
                }
                
                if let userProfileColor = user.profileColor {
                    self?.hasProfileColor = true
                }
                else {
                    self?.hasProfileColor = false
                }
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
        householdService.household
            .dropFirst()
            .sink { [weak self] household in
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
