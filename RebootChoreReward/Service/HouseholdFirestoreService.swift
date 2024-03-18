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
    static let shared = HouseholdFirestoreService()
    
    let db = Firestore.firestore()
    var householdCollectionListener: ListenerRegistration?
    var household: AnyPublisher<Household, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<Household, Never>(.empty)
    
    private init() {}
    
    func createHousehold(from householdObject: Household) {
        do {
            try db.collection("households").document(householdObject.id).setData(from: householdObject)
        } catch let error {
            print("Error writing household to Firestore: \(error)")
        }
    }
    
    func readHousehold(withId householdId: String) {
        self.householdCollectionListener = db.collection("households").document(householdId).addSnapshotListener({ [weak self] documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                if let error = error {
                    LogUtil.log("Error fetching household document: \(error)")
                }
                else {
                    LogUtil.log("Household document does not exist")
                }
                self?._household.send(.empty)
                return
            }

            do {
                if let household = try documentSnapshot?.data(as: Household.self) {
                    self?._household.send(household)
                }
                else {
                    LogUtil.log("Error decoding household document")
                    self?._household.send(.empty)
                }
            }
            catch {
                LogUtil.log("Error decoding household document \(error)")
                self?._household.send(.empty)
                return
            }
        })
    }
    
    deinit {
        householdCollectionListener?.remove()
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
