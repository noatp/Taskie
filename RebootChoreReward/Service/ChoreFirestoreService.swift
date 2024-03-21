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
    func createChore(from choreObject: Chore) async throws
    func readChores(inHousehold householdId: String)
}

class ChoreFirestoreService: ChoreService {
    private var choresSupscription: AnyCancellable?
    private let choreRepository: ChoreFirestoreRepository
    
    var chores: AnyPublisher<[Chore], Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = PassthroughSubject<[Chore], Never>()
    
    init(choreRepository: ChoreFirestoreRepository) {
        self.choreRepository = choreRepository
        subscribeToChoreRepository()
    }
    
    private func subscribeToChoreRepository() {
        choresSupscription = choreRepository.chores.sink(
            receiveValue: { [weak self] chores in
                self?._chores.send(chores)
            }
        )
    }
    
    func createChore(from choreObject: Chore) async throws {
        choreRepository.createChore(from: choreObject)
    }
    
    func readChores(inHousehold householdId: String) {
        choreRepository.readChores(inHousehold: householdId)
    }
}

class ChoreMockService: ChoreService {
    var chores: AnyPublisher<[Chore], Never> {
        Just([
            .mock,
            .mock
        ]).eraseToAnyPublisher()
    }
    
    func createChore(from choreObject: Chore) async throws {}
    
    func readChores(inHousehold householdId: String) {}
}
