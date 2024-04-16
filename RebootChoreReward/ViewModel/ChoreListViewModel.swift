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
    private var choreService: ChoreService
    
    init(choreService: ChoreService) {
        self.choreService = choreService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.chores.sink { [weak self] chores in
            LogUtil.log("Received chores \(chores)")

            self?.chores = chores
        }
        .store(in: &cancellables)
    }
    
    func readSelectedChore(choreId: String){
        choreService.readSelectedChore(choreId: choreId)
    }
}

extension Dependency.ViewModel {
    func choreListViewModel() -> ChoreListViewModel {
        return ChoreListViewModel(choreService: service.choreService)
    }
}
