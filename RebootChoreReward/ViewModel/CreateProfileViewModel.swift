
//  CreateProfileViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/27/24.
//

import Combine
import Foundation

class CreateProfileViewModel: ObservableObject {
    var name: String?
    
    private let householdService: HouseholdService
    private let userService: UserService
    private let authService: AuthService
    private var cancellables: Set<AnyCancellable> = []
    private var currentHousehold: Household?
    
    init(
        householdService: HouseholdService,
        userService: UserService,
        authService: AuthService
    ) {
        self.householdService = householdService
        self.userService = userService
        self.authService = authService
        subscribeToHouseholdFirestoreService()
    }
    
    private func subscribeToHouseholdFirestoreService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("Received household \(household)")
            self?.currentHousehold = household
        }
        .store(in: &cancellables)
    }
    
    func createHouseholdAndUser(completion: @escaping (String?) -> Void) {
        guard let name = name,
              let currentUserId = self.authService.currentUserId
        else {
            return
        }
        
        Task {
            do {
                var householdId = ""
                
                if let household = currentHousehold {
                    householdId = household.id
                }
                else {
                    householdId = UUID().uuidString
                    self.householdService.createHousehold(withId: householdId)
                }
                
                try await self.userService.createUser(
                    from: User(
                        name: name,
                        id: currentUserId,
                        household: householdId,
                        role: .parent
                    ),
                    inHousehold: householdId
                )
                completion(nil)
            }
            catch {
                completion("Error creating user and household: \(error.localizedDescription)")
            }
        }
    }
}

extension Dependency.ViewModel {
    func createProfileViewModel() -> CreateProfileViewModel {
        return CreateProfileViewModel(householdService: service.householdService, userService: service.userService, authService: service.authService)
    }
}
