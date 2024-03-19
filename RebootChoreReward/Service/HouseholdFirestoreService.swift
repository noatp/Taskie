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
}

class HouseholdFirestoreService: HouseholdService {
    static let shared = HouseholdFirestoreService(householdRepository: .shared)
    private var householdSubscription: AnyCancellable?
    private var householdRepository: HouseholdFirestoreRepository
    
    var household: AnyPublisher<Household, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = PassthroughSubject<Household, Never>()
    
    init(householdRepository: HouseholdFirestoreRepository) {
        self.householdRepository = householdRepository
        subscribeToHouseholdRepository()
    }
    
    private func subscribeToHouseholdRepository() {
        householdSubscription = householdRepository.household.sink(
            receiveValue: { [weak self] household in
                self?._household.send(household)
            }
        )
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
}
