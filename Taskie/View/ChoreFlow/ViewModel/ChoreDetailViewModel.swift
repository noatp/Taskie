
//  ChoreDetailViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import Combine
import FirebaseFirestoreInternal

class ChoreDetailViewModel: ObservableObject {
    @Published var choreDetail: Chore?
    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let choreMapper: ChoreMapper
    
    init(
        choreService: ChoreService,
        userService: UserService,
        choreMapper: ChoreMapper
    ) {
        self.choreService = choreService
        self.userService = userService
        self.choreMapper = choreMapper
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.selectedChore.sink { [weak self] choreDto in
            LogUtil.log("From ChoreService -- chore -- \(choreDto)")
            guard let choreDto = choreDto else {
                return
            }
            self?.choreDetail = self?.choreMapper.getChoreFrom(choreDto)
        }
        .store(in: &cancellables)
    }

    func acceptSelectedChore() {
        guard let currentUserId = userService.getCurrentUser()?.id else {
            return
        }
        choreService.acceptSelectedChore(acceptorId: currentUserId)
    }
    
    func finishedSelectedChore() {
        choreService.finishedSelectedChore()
    }
    
    func withdrawSelectedChore() {
        choreService.withdrawSelectedChore()
    }
}

extension Dependency.ViewModel {
    func choreDetailViewModel() -> ChoreDetailViewModel {
        return ChoreDetailViewModel(
            choreService: service.choreService,
            userService: service.userService,
            choreMapper: mapper.choreMapper
        )
    }
}
