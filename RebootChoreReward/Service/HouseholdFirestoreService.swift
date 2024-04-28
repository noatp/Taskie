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
    func createHousehold(from householdObject: Household)
    func readHousehold(withId householdId: String)
    func requestInviteCode(completion: @escaping (Bool) -> Void)
}

class HouseholdFirestoreService: HouseholdService {
    private var cancellables: Set<AnyCancellable> = []
    private var householdRepository: HouseholdFirestoreRepository
    private var userRepository: UserFirestoreRepository
    
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
    
    func requestInviteCode(completion: @escaping (Bool) -> Void) {
        let functions = Functions.functions()
        let householdId = userRepository.currentHouseholdId()
        guard !householdId.isEmpty else {
            return
        }
        functions.httpsCallable("generateInviteCode").call(["householdId": householdId]) { result, error in
            if let error = error {
                LogUtil.log("\(error.localizedDescription)")
                completion(false)
            } else if let data = result?.data as? [String: Any], let success = data["success"] as? Bool {
                completion(success)
            } else {
                completion(false)
            }
        }
    }
}

class HouseholdMockService: HouseholdService {
    var household: AnyPublisher<Household?, Never>{
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func requestInviteCode(completion: @escaping (Bool) -> Void) {}
        
    func createHousehold(from householdObject: Household) {}
    
    func readHousehold(withId householdId: String) {}
}
