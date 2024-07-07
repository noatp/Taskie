//
//  RewardBalanceViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 7/6/24.
//

import Combine

class RewardBalanceViewModel: ObservableObject {
    @Published var userBalance: Float = 0.0
    private var cancellables: Set<AnyCancellable> = []
    private let userService: UserService
    
    init(
        userService: UserService
    ) {
        self.userService = userService
        subscribeToUserService()
    }
    
    private func subscribeToUserService() {
        userService.user.sink { [weak self] user in
            guard let user = user else {
                return
            }
            LogUtil.log("From UserService -- user -- \(user)")
            self?.userBalance = user.balance
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func rewardBalanceViewModel() -> RewardBalanceViewModel {
        return RewardBalanceViewModel(
            userService: service.userService
        )
    }
}
