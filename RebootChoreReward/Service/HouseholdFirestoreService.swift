//
//  HouseholdFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine
import FirebaseFunctions
import FirebaseAuth

protocol HouseholdService {
    var household: AnyPublisher<Household?, Never> { get }
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> { get }
    func createHousehold(withId householdId: String)
    func readHousehold(withId householdId: String)
    func sendHouseholdIdReceivedFromLink(householdId: String)
    func resetHouseholdIdReceivedFromLink()
}

class HouseholdFirestoreService: HouseholdService {
    private var cancellables: Set<AnyCancellable> = []
    private var householdRepository: HouseholdFirestoreRepository
    private var userRepository: UserFirestoreRepository
    
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> {
        _householdIdReceivedFromLink.eraseToAnyPublisher()
    }
    private let _householdIdReceivedFromLink = CurrentValueSubject<String?, Never>(nil)
    
    var household: AnyPublisher<Household?, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<Household?, Never>(nil)
    
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
            LogUtil.log("Received household \(household)")
            self?._household.send(household)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.userHouseholdId.sink { [weak self] householdId in
            LogUtil.log("Received householdId \(householdId)")
            guard let householdId = householdId, !householdId.isEmpty else {
                self?._household.send(nil)
                return
            }
            self?.readHousehold(withId: householdId)
        }
        .store(in: &cancellables)
    }
    
    func createHousehold(withId householdId: String) {
        let householdObject = Household(id: householdId)
        householdRepository.createHousehold(from: householdObject)
    }
    
    func readHousehold(withId householdId: String) {
        householdRepository.readHousehold(withId: householdId)
    }
    
    func sendHouseholdIdReceivedFromLink(householdId: String) {
        self._householdIdReceivedFromLink.send(householdId)
    }
    
    func resetHouseholdIdReceivedFromLink() {
        self._householdIdReceivedFromLink.send(nil)
    }
}

class HouseholdMockService: HouseholdService {
    func sendHouseholdIdReceivedFromLink(householdId: String) {}
    
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> {
        Just("").eraseToAnyPublisher()
    }
    
    func resetHouseholdIdReceivedFromLink() {}
        
    var household: AnyPublisher<Household?, Never>{
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func createHousehold(withId householdId: String) {}
    
    func readHousehold(withId householdId: String) {}
}
