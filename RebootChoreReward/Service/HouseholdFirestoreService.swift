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
