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
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?
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
            LogUtil.log("From HouseholdRepository -- household -- \(household)")
            self?._household.send(household)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] (user, error) in
            LogUtil.log("From UserRepository -- user -- \((user, error))")
            if let user = user,
               let householdId = user.householdId {
                self?.readHousehold(withId: householdId)
            }
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
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String? {
        do {
            let householdId = try await householdRepository.readHouseholdIdFromInvitation(withEmail: email)
            return householdId
        }
        catch {
            LogUtil.log(error.localizedDescription)
            return nil
        }
    }
}

class HouseholdMockService: HouseholdService {
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?{ return nil }
    
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
