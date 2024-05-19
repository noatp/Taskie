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
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
        
    func createChore(from choreObject: Chore, inHousehold householdId: String) async {
        let choreDocRef = db.collection("households").document(householdId).collection("chores").document(choreObject.id)
        
        do {
            try await choreDocRef.setDataAsync(from: choreObject)
        }
        catch {
            LogUtil.log("Error writing chore to Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func readChores(inHousehold householdId: String) {
        householdChoreCollectionRef = db.collection("households").document(householdId).collection("chores")
        guard let householdChoreCollectionRef = householdChoreCollectionRef else {
            return
        }
        self.choreCollectionListener = householdChoreCollectionRef
            .order(by: "createdDate", descending: true)
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                        self?._error.send(nil)
                    }
                    return
                }
                
                let chores = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: Chore.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        self?._error.send(error)
                        return nil
                    }
                }
                
                self?._chores.send(chores)
            }
    }
    
    func updateChoreWithAcceptor(choreId: String, acceptorId: String) async {
        guard let householdChoreCollectionRef = householdChoreCollectionRef else {
            return
        }
        
        let choreDocRef = householdChoreCollectionRef.document(choreId)
        
        do {
            try await choreDocRef.updateData(["acceptorID": acceptorId])
        }
        catch {
            LogUtil.log("Error writing chore to Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func updateChoreWithFinishedDate(choreId: String) async {
        guard let householdChoreCollectionRef = householdChoreCollectionRef else {
            return
        }
        
        let choreDocRef = householdChoreCollectionRef.document(choreId)
        
        do {
            try await choreDocRef.updateData(["finishedDate": Timestamp.init()])
        }
        catch {
            LogUtil.log("Error writing chore to Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func removeChore(choreId: String) async {
        guard let hosueholdChoreCollectionRef = householdChoreCollectionRef else {
            return
        }
        
        let choreDocRef = householdChoreCollectionRef?.document(choreId)
        
        do {
            try await choreDocRef?.delete()
        }
        catch {
            LogUtil.log("Error deleting chore from Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func reset() {
        LogUtil.log("ChoreRepository -- resetting")
        choreCollectionListener?.remove()
        choreCollectionListener = nil
        _chores.send(nil)
        _error.send(nil)
    }
    
    deinit {
        choreCollectionListener?.remove()
    }
}
