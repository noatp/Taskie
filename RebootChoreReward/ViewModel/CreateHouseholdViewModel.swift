
//  CreateHouseholdViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Combine

class CreateHouseholdViewModel: ObservableObject {
    var tag: String?
    
    private let householdService: HouseholdService
    private let userService: UserService
    private var curentUser: User?
    private var cancellables: Set<AnyCancellable> = []
    
    
    init(
        householdService: HouseholdService,
        userService: UserService
    ) {
        self.householdService = householdService
        self.userService = userService
        subscribeToUserService()
    }
    
    private func subscribeToUserService() {
        userService.user.sink { [weak self] user in
            LogUtil.log("From UserService -- user -- \(user)")
            self?.curentUser = user
        }
        .store(in: &cancellables)
    }
    
    func createHousehold() {
        guard let currentUser = curentUser else {
            return
        }
        let decentralizedUser = DecentrailizedUser(id: currentUser.id, name: currentUser.id)
        householdService.createHousehold(forUser: decentralizedUser, withHouseholdTag: tag)
    }
}

extension Dependency.ViewModel {
    func createHouseholdViewModel() -> CreateHouseholdViewModel {
        return CreateHouseholdViewModel(householdService: service.householdService, userService: service.userService)
    }
}
