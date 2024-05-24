//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import Combine
import FirebaseAuth

enum UserServiceError: Error, LocalizedError {
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User information not found. Please try again later."
        }
    }
}

protocol UserService {
    var user: AnyPublisher<User?, Never> { get }
    var familyMembers: AnyPublisher<[DenormalizedUser]?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func createUserInHouseholdSub(householdId: String, withUser denormalizedUser: DenormalizedUser)
    func readFamilyMember(withId lookUpId: String) -> DenormalizedUser?
    func updateUserWithName(_ name: String)
    func updateUserWithProfileColor(_ profileColor: String)
    func updateUserWithHouseholdId(_ householdId: String)
    func getCurrentUser() -> User?
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    var user: AnyPublisher<User?, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<User?, Never>(nil)
    
    var familyMembers: AnyPublisher<[DenormalizedUser]?, Never> {
        _familyMembers.eraseToAnyPublisher()
    }
    private let _familyMembers = CurrentValueSubject<[DenormalizedUser]?, Never>(nil)
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    init(
        userRepository: UserRepository,
        householdRepository: HouseholdRepository
    ) {
        self.userRepository = userRepository
        self.householdRepository = householdRepository
        subscribeToUserRepository()
        subscribeToHouseholdRepository()
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] user in
            LogUtil.log("From UserRepository -- user -- \(user)")
            self?._user.send(user)
        }
        .store(in: &cancellables)
        
        userRepository.members.sink { [weak self] members in
            LogUtil.log("From UserRepository -- members -- \(members)")
            self?._familyMembers.send(members)
        }
        .store(in: &cancellables)
        
        userRepository.error.sink { [weak self] error in
            LogUtil.log("From UserRepository -- error -- \(error)")
            self?._error.send(error)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] household in            
            if let household = household, !household.id.isEmpty {
                LogUtil.log("From HouseholdRepository -- household -- \(household), reading members")
                self?.readFamilyMembersInHousehold(withHouseholdId: household.id)
            }
        }
        .store(in: &cancellables)
    }
    
    func createUserInHouseholdSub(householdId: String, withUser denormalizedUser: DenormalizedUser) {
        Task {
            await userRepository.createUserInHouseholdSub(householdId: householdId, withUser: denormalizedUser)
        }
    }
    
    func readFamilyMember(withId lookUpId: String) -> DenormalizedUser? {
        if let familyMember = _familyMembers.value?.first(where: { $0.id == lookUpId }) {
            return familyMember
        } else {
            self._error.send(UserServiceError.userNotFound)
            return nil
        }
    }
    
    func readFamilyMembersInHousehold(withHouseholdId householdId: String) {
        userRepository.readMembers(inHousehold: householdId)
    }
    
    func updateUserWithName(_ name: String) {
        Task {
            guard let currentUserId = _user.value?.id else {
                return
            }
            await userRepository.updateUser(atUserId: currentUserId, withName: name)
        }
    }
    
    func updateUserWithProfileColor(_ profileColor: String) {
        Task {
            guard let currentUserId = _user.value?.id else {
                return
            }
            await userRepository.updateUser(atUserId: currentUserId, withProfileColor: profileColor)
        }
    }
    
    func updateUserWithHouseholdId(_ householdId: String){
        Task {
            guard let currentUserId = _user.value?.id else {
                return
            }
            await userRepository.updateUser(atUserId: currentUserId, withHouseholdId: householdId)
        }
    }
    
    func getCurrentUser() -> User? {
        _user.value
    }
}

class UserMockService: UserService {
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    var user: AnyPublisher<User?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    var familyMembers: AnyPublisher<[DenormalizedUser]?, Never> {
        Just (
            [.mock, .mock, .mock]
        )
        .eraseToAnyPublisher()
    }
    func createUserInHouseholdSub(householdId: String, withUser denormalizedUser: DenormalizedUser) {}
    func readFamilyMember(withId lookUpId: String) -> DenormalizedUser? { return .mock }
    func updateUserWithName(_ name: String) {}
    func updateUserWithProfileColor(_ profileColor: String) {}
    func updateUserWithHouseholdId(_ householdId: String) {}
    func getCurrentUser() -> User? { return .mock }
}
