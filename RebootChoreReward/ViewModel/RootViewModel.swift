//
//  RootViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var authState: Bool = false
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
    }
    
    private func subscribeToAuthService() {
        authService.isUserLoggedIn.sink { [weak self] isUserLoggedIn in
            self?.authState = isUserLoggedIn
            if isUserLoggedIn {
                guard let uid = self?.authService.getCurrentUserCache(key: "uid"),
                      !uid.isEmpty
                else {
                    return
                }
                self?.userService.readUser(withId: uid)
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
