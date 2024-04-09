//
//  ChoreFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine

protocol ChoreService {
    var chores: AnyPublisher<[Chore], Never> { get }
    var selectedChore: AnyPublisher<Chore, Never> { get }
    func createChore(from choreObject: Chore) async throws
    func readChores(inHousehold householdId: String)
    func readSelectedChore(choreId: String)
}

class ChoreFirestoreService: ChoreService {
    private var cancellables: Set<AnyCancellable> = []
    private let choreRepository: ChoreFirestoreRepository
    private let userRepository: UserFirestoreRepository
    private var selectedChoreId: String?
    
    var chores: AnyPublisher<[Chore], Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[Chore], Never>([])
    
    var selectedChore: AnyPublisher<Chore, Never> {
        _selectedChore.eraseToAnyPublisher()
    }
    private let _selectedChore = CurrentValueSubject<Chore, Never>(.empty)
    
    init(
        choreRepository: ChoreFirestoreRepository,
        userRepository: UserFirestoreRepository
    ) {
        self.choreRepository = choreRepository
        self.userRepository = userRepository
        subscribeToChoreRepository()
        subscribeToUserRepository()
    }
    
    private func subscribeToChoreRepository() {
        choreRepository.chores.sink(
            receiveValue: { [weak self] chores in
                self?._chores.send(chores)
                
                if let selectedChoreId = self?.selectedChoreId,
                   let selectedChore = chores.first(where: { $0.id == selectedChoreId })
                {
                    self?._selectedChore.send(selectedChore)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.userHouseholdId.sink { [weak self] householdId in
            guard !householdId.isEmpty else {
                return
            }
            self?.readChores(inHousehold: householdId)
        }
        .store(in: &cancellables)
    }
    
    func createChore(from choreObject: Chore) async throws {
        choreRepository.createChore(from: choreObject)
    }
    
    func readChores(inHousehold householdId: String) {
        choreRepository.readChores(inHousehold: householdId)
    }
    
    func readSelectedChore(choreId: String){
        self.selectedChoreId = choreId
        
        if let selectedChore = _chores.value.first(where: { $0.id == choreId }) {
            _selectedChore.send(selectedChore)
        }
    }
}

class ChoreMockService: ChoreService {
    var selectedChore: AnyPublisher<Chore, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    var chores: AnyPublisher<[Chore], Never> {
        Just([
            .mock,
            .mock
        ]).eraseToAnyPublisher()
    }
    
    func createChore(from choreObject: Chore) async throws {}
    
    func readChores(inHousehold householdId: String) {}
    
    func readSelectedChore(choreId: String) {}
}
