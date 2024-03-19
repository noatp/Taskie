//
//  ChoreFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine

protocol ChoreService {
    var chores: AnyPublisher<[Chore], Never> { get }
}

class ChoreFirestoreService: ChoreService {
    static let shared = ChoreFirestoreService(choreRepository: .shared)
    private var choresSupscription: AnyCancellable?
    private let choreRepository: ChoreFirestoreRepository
    
    var chores: AnyPublisher<[Chore], Never> {
        _chores.eraseToAnyPublisher()
    }
    private let _chores = PassthroughSubject<[Chore], Never>()
    
    init(choreRepository: ChoreFirestoreRepository) {
        self.choreRepository = choreRepository
        subscribeToChoreRepository()
    }
    
    private func subscribeToChoreRepository() {
        choresSupscription = choreRepository.chores.sink(
            receiveValue: { [weak self] chores in
                self?._chores.send(chores)
            }
        )
    }
    
    func createChore(from choreObject: Chore) async throws {
        choreRepository.createChore(from: choreObject)
    }
    
    func readChores(inHousehold householdId: String) {
        choreRepository.readChores(inHousehold: householdId)
    }
    
//    let db = Firestore.firestore()
//    var choreCollectionListener: ListenerRegistration?
//    var chores: AnyPublisher<[Chore], Never> {
//        _chores.eraseToAnyPublisher()
//    }
//    private let _chores = CurrentValueSubject<[Chore], Never>([])
//    private var choreCollectionRef: CollectionReference?
//    
//    private init() {}
//    
//    func createChore(from choreObject: Chore) async throws {
//        let jsonData = try JSONEncoder().encode(choreObject)
//        let choreData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
//        try await choreCollectionRef?.addDocument(data: choreData)
//    }
//    
//    func readChores(inHousehold householdId: String) {
//        choreCollectionRef = db.collection("households").document(householdId).collection("chores")
//        self.choreCollectionListener = choreCollectionRef?.addSnapshotListener { [weak self] collectionSnapshot, error in
//            
//            guard let collectionSnapshot = collectionSnapshot else {
//                if let error = error {
//                    LogUtil.log("\(error)")
//                }
//                return
//            }
//            
//            let chores = collectionSnapshot.documents.compactMap { documentSnapshot in
//                do {
//                    return try documentSnapshot.data(as: Chore.self)
//                }
//                catch {
//                    LogUtil.log("\(error)")
//                    return nil
//                }
//            }
//            
//            self?._chores.send(chores)
//        }
//    }
//    
//    deinit {
//        choreCollectionListener?.remove()
//    }
}

class ChoreMockService: ChoreService {
    var chores: AnyPublisher<[Chore], Never> {
        Just([
            .mock,
            .mock
        ]).eraseToAnyPublisher()
    }
    
}
