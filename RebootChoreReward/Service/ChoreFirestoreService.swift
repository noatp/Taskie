//
//  ChoreFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine

class ChoreFirestoreService {
    static let shared = ChoreFirestoreService()
    
    let db = Firestore.firestore()
    var choreCollectionListener: ListenerRegistration?
    var chores: AnyPublisher<[Chore], Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = CurrentValueSubject<[Chore], Never>([])
    
    init() {
        readChores()
    }
    
    func createChore(withChore choreObject: Chore) async throws {
        let jsonData = try JSONEncoder().encode(choreObject)
        let choreData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        try await db.collection("chores").addDocument(data: choreData)
    }
    
    func readChores() {
        self.choreCollectionListener = db.collection("chores").addSnapshotListener { [weak self] collectionSnapshot, error in
            
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
