//
//  ChoreFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine

enum ChoreServiceError: Error, LocalizedError {
    case choreNotFound
    
    var errorDescription: String? {
        switch self {
        case .choreNotFound:
            return "Chore information not found. Please try again later."
        }
    }
}

protocol ChoreService {
    var chores: AnyPublisher<[ChoreDTO]?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    var selectedChore: AnyPublisher<ChoreDTO?, Never> { get }
    func createChore(from choreObject: ChoreDTO) async
    func readChores(inHousehold householdId: String)
    func readSelectedChore(choreId: String)
    func acceptSelectedChore(acceptorId: String)
    func finishedSelectedChore()
    func withdrawSelectedChore()
    func makeSelectedChoreReadyForReview()
    func makeSelectedChoreNotReadyForReview()
}

class ChoreFirestoreService: ChoreService {
    private var cancellables: Set<AnyCancellable> = []
    private let choreRepository: ChoreRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    var chores: AnyPublisher<[ChoreDTO]?, Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[ChoreDTO]?, Never>(nil)
    
    var selectedChore: AnyPublisher<ChoreDTO?, Never> {
        _selectedChore.eraseToAnyPublisher()
    }
    private let _selectedChore = CurrentValueSubject<ChoreDTO?, Never>(nil)
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    init(
        choreRepository: ChoreRepository,
        userRepository: UserRepository,
        householdRepository: HouseholdRepository
    ) {
        self.choreRepository = choreRepository
        self.userRepository = userRepository
        self.householdRepository = householdRepository
        subscribeToHouseholdRepository()
        subscribeToChoreRepository()
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] household in
            if let household = household,
               !household.id.isEmpty
            {
                LogUtil.log("From HouseholdRepository -- household -- \(household), reading chores")
                self?.choreRepository.readChores(inHousehold: household.id)
            }
            else {
                LogUtil.log("From HouseholdRepository -- household -- nil, resetting ChoreRepository")
                self?.choreRepository.reset()
            }
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToChoreRepository() {
        choreRepository.chores.sink(
            receiveValue: { [weak self] chores in
                LogUtil.log("From ChoreRepository -- chores -- \(chores)")
                self?._chores.send(chores)
                
                if let selectedChoreId = self?._selectedChore.value?.id ,
                   let selectedChoreNewData = chores?.first(where: { $0.id == selectedChoreId})
                {
                    self?._selectedChore.send(selectedChoreNewData)
                }
                else {
                    self?._selectedChore.send(nil)
                }
            }
        )
        .store(in: &cancellables)
        
        choreRepository.error.sink { [weak self] error in
            LogUtil.log("From ChoreRepository -- error -- \(error)")
            self?._error.send(error)
        }
        .store(in: &cancellables)
    }
    
    func createChore(from choreObject: ChoreDTO) async {
        guard let householdId = householdRepository.currentHouseholdId(), !householdId.isEmpty else {
            return
        }
        await choreRepository.createChore(from: choreObject, inHousehold: householdId)
    }
    
    func readChores(inHousehold householdId: String) {
        choreRepository.readChores(inHousehold: householdId)
    }
    
    func readSelectedChore(choreId: String){
        if let selectedChore = _chores.value?.first(where: { $0.id == choreId }) {
            _selectedChore.send(selectedChore)
        }
        else {
            _error.send(ChoreServiceError.choreNotFound)
        }
    }
    
    func acceptSelectedChore(acceptorId: String) {
        Task {
            guard let selectedChore = self._selectedChore.value else {
                return
            }
            await choreRepository.updateChoreWithAcceptor(choreId: selectedChore.id, acceptorId: acceptorId)
        }
    }
    
    func finishedSelectedChore(){
        Task {
            guard let selectedChore = self._selectedChore.value else {
                return
            }
            await choreRepository.updateChoreWithFinishedDate(choreId: selectedChore.id)
        }
    }
    
    func withdrawSelectedChore() {
        Task {
            guard let selectedChore = self._selectedChore.value else {
                return
            }
            
            await choreRepository.removeChore(choreId: selectedChore.id)
        }
    }
    
    func makeSelectedChoreReadyForReview() {
        Task {
            guard let selectedChore = self._selectedChore.value else {
                return
            }
            await choreRepository.updateChoreWithReviewStatus(choreId: selectedChore.id, isReadyForReview: true)
        }
    }
    
    func makeSelectedChoreNotReadyForReview() {
        Task {
            guard let selectedChore = self._selectedChore.value else {
                return
            }
            await choreRepository.updateChoreWithReviewStatus(choreId: selectedChore.id, isReadyForReview: false)
        }
    }
}

class ChoreMockService: ChoreService {
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    var selectedChore: AnyPublisher<ChoreDTO?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    var chores: AnyPublisher<[ChoreDTO]?, Never> {
        Just([.mock,.mock]).eraseToAnyPublisher()
    }
    
    func createChore(from choreObject: ChoreDTO) async {}
    
    func readChores(inHousehold householdId: String) {}
    
    func readSelectedChore(choreId: String) {}
    
    func acceptSelectedChore(acceptorId: String) {}
    
    func finishedSelectedChore() {}
    
    func withdrawSelectedChore() {}
    
    func makeSelectedChoreReadyForReview() {}
    
    func makeSelectedChoreNotReadyForReview() {}
}
