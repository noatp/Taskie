
//  CreateOrAddHouseholdViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Combine

class CreateOrJoinHouseholdViewModel: ObservableObject {
    @Published var hasInvite: Bool = false
    private var householdIdFromInvite: String? = nil
    
    private var householdService: HouseholdService
    private var userService: UserService		
    private var authService: AuthService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userService: UserService,
        householdService: HouseholdService,
        authService: AuthService
    ) {
        self.userService = userService
        self.householdService = householdService
        self.authService = authService
        self.checkInvite()
    }
    
    func checkInvite() {
        Task {
            if let householdIdFromUniversalLink = householdService.readHouseholdIdFromUniversalLink() {
                hasInvite = true
                householdIdFromInvite = householdIdFromUniversalLink
                return
            }
            else if let currentUserEmail = authService.getCurrentUserEmail(),
                    let householdIdFromInvitation = await householdService.readHouseholdIdFromInvitation(withEmail: currentUserEmail) {
                hasInvite = true
                householdIdFromInvite = householdIdFromInvitation
                return
            }
        }
    }
    
    func joinHouseholdFromInvite() {
        guard let householdIdFromInvite = householdIdFromInvite,
              let currentUser = userService.getCurrentUser()
        else {
            return
        }
        
        
        userService.createUserInHouseholdSub(
            householdId: householdIdFromInvite,
            withUser: .init(
                id: currentUser.id,
                name: currentUser.name,
                profileColor: currentUser.profileColor
            )
        )
        
        userService.updateUserWithHouseholdId(householdIdFromInvite)
    }
}

extension Dependency.ViewModel {
    func createOrAddHouseholdViewModel() -> CreateOrJoinHouseholdViewModel {
        return CreateOrJoinHouseholdViewModel(
            userService: service.userService,
            householdService: service.householdService,
            authService: service.authService
        )
    }
}
