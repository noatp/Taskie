//
//  RootViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var hasUserData: Bool = false
    @Published var errorMessage: String? = nil
//    var isLoggedIn: Bool = false
    
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
    }
    
    private func subscribeToAuthService() {
//        authService.isUserLoggedIn.sink { [weak self] isUserLoggedIn in
//            LogUtil.log("Received isUserLoggedIn \(isUserLoggedIn)")
//
//            self?.isLoggedIn = isUserLoggedIn
//            if isUserLoggedIn {
//                guard let currentUserId = self?.authService.currentUserId,
//                      !currentUserId.isEmpty else {
//                    return
//                }
//                self?.userService.readUser(withId: currentUserId)
//            }
//        }
//        .store(in: &cancellables)
        
        authService.silentLogIn()
    }
    
    private func subscribeToUserService() {
        userService.user.sink { [weak self] (user, error) in
            if let error = error {
                self?.errorMessage = "Error fetching user data from server."
            }
            if let user = user {
                self?.hasUserData = true
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
