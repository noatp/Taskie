//
//  HouseholdFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine

protocol HouseholdService {
    var household: AnyPublisher<Household, Never> { get }
    func createHousehold(from householdObject: Household)
    func readHousehold(withId householdId: String)
}

class HouseholdFirestoreService: HouseholdService {
    private var cancellables: Set<AnyCancellable> = []
    private var householdRepository: HouseholdFirestoreRepository
    private var userRepository: UserFirestoreRepository
    
    var household: AnyPublisher<Household, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = PassthroughSubject<Household, Never>()
    
    init(
        householdRepository: HouseholdFirestoreRepository,
        userRepository: UserFirestoreRepository
    ) {
        self.householdRepository = householdRepository
        self.userRepository = userRepository
        subscribeToHouseholdRepository()
        subscribeToUserRepository()
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] household in
            self?._household.send(household)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.userHouseholdId.sink { [weak self] householdId in
            guard !householdId.isEmpty else {
                return
            }
            self?.readHousehold(withId: householdId)
        }
        .store(in: &cancellables)
    }
    
    func createHousehold(from householdObject: Household) {
        householdRepository.createHousehold(from: householdObject)
    }
    
    func readHousehold(withId householdId: String) {
        householdRepository.readHousehold(withId: householdId)
    }
}

class HouseholdMockService: HouseholdService {
    var household: AnyPublisher<Household, Never> {
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func createHousehold(from householdObject: Household) {}
    
    func readHousehold(withId householdId: String) {}
}
