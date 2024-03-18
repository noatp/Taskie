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
    
    init(
        authService: AuthService = AuthService.shared,
        userService: UserService = UserFirestoreService.shared,
        householdService: HouseholdService = HouseholdFirestoreService.shared
    ) {
        self.authService = authService
        self.userService = userService
        self.householdService = householdService
        subscribeToAuthService()
        subscribeToUserService()
        subscribeToHouseholdService()
    }
    
    private func subscribeToAuthService() {
        authService.isUserLoggedIn.sink { [weak self] isUserLoggedIn in
            self?.authState = isUserLoggedIn
            if isUserLoggedIn {
                guard let uid = AuthService.shared.getCurrentUserCache(key: "uid"),
                      !uid.isEmpty
                else {
                    return
                }
                UserFirestoreService.shared.readUser(withId: uid)
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserService() {
        userService.user.sink { user in
            guard !user.household.isEmpty else {
                return
            }
            HouseholdFirestoreService.shared.readHousehold(withId: user.household)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { household in
            guard !household.id.isEmpty else {
                return
            }
            ChoreFirestoreService.shared.readChores(inHousehold: household.id)
        }
        .store(in: &cancellables)
    }
}
