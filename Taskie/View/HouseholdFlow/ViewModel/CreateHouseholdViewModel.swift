
//  CreateHouseholdViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Combine
import Foundation

enum CreateHouseholdViewModelError: Error, LocalizedError {
    case missingTag
    case noCurrentUser
    
    var errorDescription: String? {
        switch self {
            case .missingTag:
                return "Please enter a tag name for your new household."
            case .noCurrentUser:
                return "Something went wrong. Please try again later!"
        }
    }
}

class CreateHouseholdViewModel: ObservableObject {
    @Published var tagCheckResult: Result<Void, CreateHouseholdViewModelError>?
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
            self.tagCheckResult = .failure(.noCurrentUser)
            return
        }
        
        guard let tag = tag, !tag.isEmpty else {
            self.tagCheckResult = .failure(.missingTag)
            return
        }
        
        let denormalizedUser = DenormalizedUser(id: currentUser.id, name: currentUser.name, profileColor: currentUser.profileColor)
        householdService.createHousehold(forUser: denormalizedUser, withHouseholdTag: tag)
    }
}

extension Dependency.ViewModel {
    func createHouseholdViewModel() -> CreateHouseholdViewModel {
        return CreateHouseholdViewModel(householdService: service.householdService, userService: service.userService)
    }
}
