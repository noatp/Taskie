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
    
    func readUser(withId userId: String) {
        self.userCollectionListener = db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                if let error = error {
                    LogUtil.log("Error fetching user document: \(error)")
                }
                else {
                    LogUtil.log("User document does not exist")
                }
                self?._user.send(.empty)
                return
            }

            do {
                if let user = try documentSnapshot?.data(as: User.self) {
                    self?._user.send(user)
                }
                else {
                    LogUtil.log("Error decoding user document")
                    self?._user.send(.empty)
                }
            }
            catch {
                LogUtil.log("Error decoding user document \(error)")
                self?._user.send(.empty)
                return
            }
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
