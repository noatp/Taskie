
//  HouseholdMemberListViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/8/24.
//

import Combine

class HouseholdMemberListViewModel: ObservableObject {
    @Published var familyMembers: [DecentrailizedUser] = []
    private var cancellables: Set<AnyCancellable> = []
    private var userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
        subscribeToUserFirestoreService()
    }
    
    private func subscribeToUserFirestoreService() {
        userService.familyMembers.sink { [weak self] (familyMembers, _) in
            LogUtil.log("From UserService -- familyMembers -- \(familyMembers)")
            guard let familyMembers = familyMembers else {
                return
            }
            self?.familyMembers = familyMembers
        }
        .store(in: &cancellables)
    }
    
    
}

extension Dependency.ViewModel {
    func householdMemberListViewModel() -> HouseholdMemberListViewModel {
        return HouseholdMemberListViewModel(userService: service.userService)
    }
}
