//
//  HouseholdFirestoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

class HouseholdFirestoreRepository {
    private let db = Firestore.firestore()
    private var householdCollectionListener: ListenerRegistration?
    var household: AnyPublisher<Household?, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<Household?, Never>(nil)
    
    init() {}
    
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
                self?._household.send(nil)
                return
            }

            do {
                if let household = try documentSnapshot?.data(as: Household.self) {
                    self?._household.send(household)
                }
                else {
                    LogUtil.log("Error decoding household document")
                    self?._household.send(nil)
                }
            }
            catch {
                LogUtil.log("Error decoding household document \(error)")
                self?._household.send(nil)
                return
            }
        })
    }
    
    func reset() {
        LogUtil.log("resetting")
        householdCollectionListener?.remove()
        householdCollectionListener = nil
        _household.send(nil)
    }
    
    deinit {
        householdCollectionListener?.remove()
    }
}
