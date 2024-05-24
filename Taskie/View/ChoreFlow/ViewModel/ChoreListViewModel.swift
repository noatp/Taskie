//
//  ChoreListViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/9/24.
//

import Combine

class ChoreListViewModel: ObservableObject {
    @Published var chores: [Chore] = []
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
        self.choreMapper = choreMapper
        self.userService = userService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.chores
            .combineLatest(userService.familyMembers)
            .sink { [weak self] chores, familyMembers in
            guard let chores = chores,
                  let familyMembers = familyMembers, !familyMembers.isEmpty,
                  let self = self
            else {
                return
            }
            self.chores = chores.compactMap{ self.choreMapper.getChoreFrom($0) }
        }
        .store(in: &cancellables)
    }
    
    func readSelectedChore(choreId: String){
        choreService.readSelectedChore(choreId: choreId)
    }
}

extension Dependency.ViewModel {
    func choreListViewModel() -> ChoreListViewModel {
        return ChoreListViewModel(
            choreService: service.choreService,
            userService: service.userService, 
            choreMapper: mapper.choreMapper
        )
    }
}
