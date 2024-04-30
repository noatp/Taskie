
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
    private var householdIdReceivedFromLink: String?
    
    init(
        householdService: HouseholdService,
        userService: UserService,
        authService: AuthService
    ) {
        self.householdService = householdService
        self.userService = userService
        self.authService = authService
    }
    
    private func subscribeToHouseholdService() {
        householdService.householdIdReceivedFromLink.sink { [weak self] householdId in
            self?.householdIdReceivedFromLink = householdId
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
                
                if let householdId = self.householdIdReceivedFromLink {
                    householdService.readHousehold(withId: householdId)
                    householdService.resetHouseholdIdReceivedFromLink()
                } else {
                    let newHouseholdId = UUID().uuidString
                    householdService.createHousehold(withId: newHouseholdId)
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
