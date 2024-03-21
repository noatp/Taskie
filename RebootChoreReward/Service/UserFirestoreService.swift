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
    func createUser(from userObject: User)
    func readUser(withId userId: String)
    
}

class UserFirestoreService: UserService {
    private var userSubscription: AnyCancellable?
    private let userRepository: UserFirestoreRepository
    
    var user: AnyPublisher<User, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = PassthroughSubject<User, Never>()
    
    init(userRepository: UserFirestoreRepository) {
        self.userRepository = userRepository
        subscribeToUserRepository()
    }
    
    private func subscribeToUserRepository() {
        userSubscription = userRepository.user.sink(
            receiveValue: { [weak self] user in
                self?._user.send(user)
            }
        )
    }
    
    func createUser(from userObject: User) {
        userRepository.createUser(from: userObject)
    }

    
    func readUser(withId userId: String) {
        userRepository.readUser(withId: userId)
    }
}

class UserMockService: UserService {
    var user: AnyPublisher<User, Never> {
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func createUser(from userObject: User) {}

    
    func readUser(withId userId: String) {}
}
