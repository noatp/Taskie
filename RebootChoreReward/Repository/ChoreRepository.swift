//
//  ChoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

class ChoreRepository {
    private let db = Firestore.firestore()
    private var choreCollectionListener: ListenerRegistration?
    private var householdChoreCollectionRef: CollectionReference?
    var chores: AnyPublisher<[Chore]?, Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[Chore]?, Never>(nil)
        
    func createChore(from choreObject: Chore, inHousehold householdId: String) {
        householdChoreCollectionRef = db.collection("households").document(householdId).collection("chores")
        do {
            try householdChoreCollectionRef?.document(choreObject.id).setData(from: choreObject)
        }
        catch let error {
            LogUtil.log("Error writing chore to Firestore: \(error)")
        }
    }
    
    func readChores(inHousehold householdId: String) {
        householdChoreCollectionRef = db.collection("households").document(householdId).collection("chores")
        self.choreCollectionListener = householdChoreCollectionRef?
            .order(by: "createdDate", descending: true)
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                        self?._chores.send(nil)
                    }
                    return
                }
                
                let chores = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: Chore.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        return nil
                    }
                }
                
                self?._chores.send(chores)
            }
    }
    
    func reset() {
        LogUtil.log("ChoreRepository -- resetting")
        choreCollectionListener?.remove()
        choreCollectionListener = nil
        householdChoreCollectionRef = nil
        _chores.send(nil)
    }
    
    deinit {
        choreCollectionListener?.remove()
    }
}
