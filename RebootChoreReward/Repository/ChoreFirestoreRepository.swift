//
//  ChoreFirestoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

class ChoreFirestoreRepository {    
    static let shared = ChoreFirestoreRepository.init()
    private let db = Firestore.firestore()
    private var choreCollectionListener: ListenerRegistration?
    private var choreCollectionRef: CollectionReference?
    var chores: AnyPublisher<[Chore], Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[Chore], Never>([])
    
    private init() {}
    
    func createChore(from choreObject: Chore) {
        do {
            try choreCollectionRef?.document(UUID().uuidString).setData(from: choreObject)
        }
        catch let error {
            LogUtil.log("Error writing chore to Firestore: \(error)")
        }
    }
    
    func readChores(inHousehold householdId: String) {
        choreCollectionRef = db.collection("households").document(householdId).collection("chores")
        self.choreCollectionListener = choreCollectionRef?.addSnapshotListener { [weak self] collectionSnapshot, error in
            guard let collectionSnapshot = collectionSnapshot else {
                if let error = error {
                    LogUtil.log("\(error)")
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
    
    deinit {
        choreCollectionListener?.remove()
    }
}
