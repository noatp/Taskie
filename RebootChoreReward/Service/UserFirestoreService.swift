//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import FirebaseFirestore
import Combine

protocol UserService {
    var user: AnyPublisher<User, Never> { get }
}

class UserFirestoreService: UserService {
    static let shared = UserFirestoreService()
    
    let db = Firestore.firestore()
    var userCollectionListener: ListenerRegistration?
    var user: AnyPublisher<User, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<User, Never>(.empty)
    
    private init() {}
    
    func createUser(from userObject: User) {
        do {
            try db.collection("users").document(userObject.id).setData(from: userObject)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
    
    deinit {
        userCollectionListener?.remove()
    }
}

class UserMockService: UserService {
    var user: AnyPublisher<User, Never> {
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
}
