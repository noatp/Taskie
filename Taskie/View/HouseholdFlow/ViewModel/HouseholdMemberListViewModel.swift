
//  HouseholdMemberListViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/8/24.
//

import Combine

class HouseholdMemberListViewModel: ObservableObject {
    @Published var familyMembers: [DenormalizedUser] = []
    private var cancellables: Set<AnyCancellable> = []
    private let userService: UserService
    private let householdService: HouseholdService
    
    init(
        userService: UserService,
        householdService: HouseholdService
    ) {
        self.userService = userService
        self.householdService = householdService
        subscribeToUserFirestoreService()
    }
    
    private func subscribeToUserFirestoreService() {
        userService.familyMembers.sink { [weak self] familyMembers in
            LogUtil.log("From UserService -- familyMembers -- \(familyMembers)")
            guard let familyMembers = familyMembers else {
                return
            }
            self?.familyMembers = familyMembers
        }
        .store(in: &cancellables)
    }
    
    func getInviteLink() -> String? {
        guard let currentHouseholdId = householdService.getCurrentHousehold()?.id else {
            return nil
        }
        
        return "https://get-taskie.app/invite/\(currentHouseholdId)"
    }
}

extension Dependency.ViewModel {
    func householdMemberListViewModel() -> HouseholdMemberListViewModel {
        return HouseholdMemberListViewModel(
            userService: service.userService,
            householdService: service.householdService
        )
    }
}
