
//  ChoreDetailViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import Combine

class ChoreDetailViewModel: ObservableObject {
    @Published var chore: Chore = .empty
    private var cancellables: Set<AnyCancellable> = []
    private var choreService: ChoreService
    
    init(choreService: ChoreService) {
        self.choreService = choreService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.selectedChore.sink { [weak self] chore in
            self?.chore = chore
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func choreDetailViewModel() -> ChoreDetailViewModel {
        return ChoreDetailViewModel(choreService: service.choreService)
    }
}
