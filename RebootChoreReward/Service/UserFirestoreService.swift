//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import Combine

protocol UserService {
    var user: AnyPublisher<User, Never> { get }
    var familyMembers: [User] { get }
    func createUser(from userObject: User)
    func readUser(withId userId: String)
    func readFamilyMember(withId lookUpId: String) async throws -> User
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserFirestoreRepository
    var familyMembers: [User] = []
    var user: AnyPublisher<User, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = PassthroughSubject<User, Never>()
    
    init(userRepository: UserFirestoreRepository) {
        self.userRepository = userRepository
        subscribeToUserRepository()
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink(
            receiveValue: { [weak self] user in
                self?._user.send(user)
            }
        )
        .store(in: &cancellables)
    }
    
    func createUser(from userObject: User) {
        userRepository.createUser(from: userObject)
    }

    
    func readUser(withId userId: String) {
        userRepository.readUser(withId: userId)
    }
    
    func readFamilyMember(withId lookUpId: String) async throws -> User {
        if let familyMember = familyMembers.first(where: { $0.id == lookUpId }) {
            return familyMember
        } else {
            let familyMember = try await userRepository.readUser(withId: lookUpId)
            familyMembers.append(familyMember)
            return familyMember
        }
    }
}

class UserMockService: UserService {
    var familyMembers: [User] = [.mock, .mock]
    
    var user: AnyPublisher<User, Never> {
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func createUser(from userObject: User) {}

    
    func readUser(withId userId: String) {}
    
    func readFamilyMember(withId lookUpId: String) async throws -> User {return .mock}
}
