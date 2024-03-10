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
    
    init(choreService: ChoreService = ChoreFirestoreService.shared) {
        self.choreService = choreService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.chores.sink { [weak self] chores in
            self?.chores = chores
        }
        .store(in: &cancellables)
    }
    
    func createChore() async {
        do {
            try await ChoreFirestoreService.shared.createChore(withChore: Chore(name: "Test Chore", creator: "Me"))
        } catch {
            print("Error creating chore: \(error)")
        }
    }
}
