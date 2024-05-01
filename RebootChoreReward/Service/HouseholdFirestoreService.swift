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
    var household: AnyPublisher<(Household?, Error?), Never> { get }
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
    
    var household: AnyPublisher<(Household?, Error?), Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<(Household?, Error?), Never>((nil, nil))
    
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
        householdRepository.household.sink { [weak self] (household, error) in
            LogUtil.log("From HouseholdRepository -- (household, error) -- \((household, error))")
            self?._household.send((household, error))
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] (user, _) in
            LogUtil.log("From UserRepository -- user -- \(user)")
            if let user = user,
               let householdId = user.householdId,
               !householdId.isEmpty
            {
                LogUtil.log("Received valid user, reading household")
                self?.readHousehold(withId: householdId)
            }
            else {
                LogUtil.log("Received user nil, sending household (nil, nil), reseting")
                self?._household.send((nil, nil))
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
        
    var household: AnyPublisher<(Household?, Error?), Never>{
        Just(
            (.mock, nil)
        )
        .eraseToAnyPublisher()
    }
    
    func createHousehold(withId householdId: String) {}
    
    func readHousehold(withId householdId: String) {}
}
