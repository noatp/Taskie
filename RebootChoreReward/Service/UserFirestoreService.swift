//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import Combine
import FirebaseAuth

protocol UserService {
    var user: AnyPublisher<User?, Never> { get }
    var familyMembers: AnyPublisher<[User]?, Never> { get }
    func createUser(from userObject: User, inHousehold householdId: String) async throws
    func readUser(withId userId: String)
    func readFamilyMember(withId lookUpId: String) async throws -> User
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserFirestoreRepository
    
    var familyMembers: AnyPublisher<[User]?, Never> {
        _familyMembers.eraseToAnyPublisher()
    }
    private let _familyMembers = CurrentValueSubject<[User]?, Never>([])
    
    var user: AnyPublisher<User?, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = PassthroughSubject<User?, Never>()
    
    init(userRepository: UserFirestoreRepository) {
        self.userRepository = userRepository
        subscribeToUserRepository()
    }
    
    private func subscribeToUserRepository() {
        userRepository.members.sink { [weak self] members in
            LogUtil.log("Received members \(members)")

            self?._familyMembers.send(members)

            guard let self = self,
                  let currentUserId = Auth.auth().currentUser?.uid,
                  let currentUser = members?.first(where: { $0.id == currentUserId }) else {
                return
            }
            _user.send(currentUser)
        }
        .store(in: &cancellables)
        
        userRepository.userHouseholdId.sink { [weak self] householdId in
            guard let householdId = householdId, !householdId.isEmpty else {
                return
            }
            self?.userRepository.readUsers(inHousehold: householdId)
        }
        .store(in: &cancellables)
    }
    
    func createUser(from userObject: User, inHousehold householdId: String) async throws {
        try await userRepository.createUser(from: userObject, inHousehold: householdId)
    }

    func readUser(withId userId: String) {
        userRepository.readUserForHouseholdId(userId: userId)
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
    var familyMembers: AnyPublisher<[User]?, Never> {
        Just ([
            .mock,
            .mock,
            .mock
        ])
        .eraseToAnyPublisher()
    }
        
    var user: AnyPublisher<User?, Never> {
        Just(
            .mock
        )
        .eraseToAnyPublisher()
    }
    
    func createUser(from userObject: User, inHousehold householdId: String) async throws {}

    
    func readUser(withId userId: String) {}
    
    func readFamilyMember(withId lookUpId: String) async throws -> User {return .mock}
}
