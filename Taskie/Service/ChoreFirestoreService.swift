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
    var chores: AnyPublisher<[Chore]?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    var selectedChore: AnyPublisher<Chore?, Never> { get }
    func createChore(from choreObject: Chore) async throws
    func readChores(inHousehold householdId: String)
    func readSelectedChore(choreId: String)
    func acceptSelectedChore(acceptorId: String)
    func finishedSelectedChore()
}

class ChoreFirestoreService: ChoreService {
    private var cancellables: Set<AnyCancellable> = []
    private let choreRepository: ChoreRepository
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    var chores: AnyPublisher<[Chore]?, Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[Chore]?, Never>(nil)
    
    var selectedChore: AnyPublisher<Chore?, Never> {
        _selectedChore.eraseToAnyPublisher()
    }
    private let _selectedChore = CurrentValueSubject<Chore?, Never>(nil)
    
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
        subscribeToChoreRepository()
        subscribeToHouseholdRepository()
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
            }
        )
        .store(in: &cancellables)
        
        choreRepository.error.sink { [weak self] error in
            LogUtil.log("From ChoreRepository -- error -- \(error)")
            self?._error.send(error)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] household in
            LogUtil.log("From HouseholdRepository -- household -- \(household)")
            
            if let household = household,
               !household.id.isEmpty
            {
                LogUtil.log("Received valid household, reading chores")
                self?.choreRepository.readChores(inHousehold: household.id)
            }
            else {
                LogUtil.log("Received invalid householdId, resetting ChoreRepository")
                self?.choreRepository.reset()
            }
        }
        .store(in: &cancellables)
    }
    
    func createChore(from choreObject: Chore) async {
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
}

class ChoreMockService: ChoreService {
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    var selectedChore: AnyPublisher<Chore?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    var chores: AnyPublisher<[Chore]?, Never> {
        Just([.mock,.mock]).eraseToAnyPublisher()
    }
    
    func createChore(from choreObject: Chore) async throws {}
    
    func readChores(inHousehold householdId: String) {}
    
    func readSelectedChore(choreId: String) {}
    
    func acceptSelectedChore(acceptorId: String) {}
    
    func finishedSelectedChore() {}
}
