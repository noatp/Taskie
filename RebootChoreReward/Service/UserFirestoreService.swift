//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import Combine
import FirebaseAuth

protocol UserService {
    var user: AnyPublisher<(User?, Error?), Never> { get }
    var familyMembers: AnyPublisher<[User]?, Never> { get }
    func readFamilyMember(withId lookUpId: String) async throws -> User
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserRepository
    
    var user: AnyPublisher<(User?, Error?), Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<(User?, Error?), Never>((nil, nil))
    
    var familyMembers: AnyPublisher<[User]?, Never> {
        _familyMembers.eraseToAnyPublisher()
    }
    private let _familyMembers = CurrentValueSubject<[User]?, Never>([])
    
    
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        subscribeToUserRepository()
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] (user, error) in
            LogUtil.log("From UserRepository -- (user, error) -- \((user, error))")
            self?._user.send((user, error))
        }
        .store(in: &cancellables)
        
        userRepository.members.sink { [weak self] members in
            LogUtil.log("From UserRepository -- members -- \(members)")

            self?._familyMembers.send(members)
        }
        .store(in: &cancellables)
    }
    
    func readFamilyMember(withId lookUpId: String) async throws -> User {
        if let familyMember = _familyMembers.value?.first(where: { $0.id == lookUpId }) {
            return familyMember
        } else {
            throw UserRepositoryError.userNotFound
        }
    }
    
    func reset() {
        
    }
}

class UserMockService: UserService {
    var user: AnyPublisher<(User?, Error?), Never> {
        Just(
            (.mock, nil)
        )
        .eraseToAnyPublisher()
    }
    
    var familyMembers: AnyPublisher<[User]?, Never> {
        Just ([
            .mock,
            .mock,
            .mock
        ])
        .eraseToAnyPublisher()
    }
    
    func readFamilyMember(withId lookUpId: String) async throws -> User {return .mock}
}
