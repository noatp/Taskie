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
    var familyMembers: AnyPublisher<[DecentrailizedUser]?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func readFamilyMember(withId lookUpId: String) async throws -> DecentrailizedUser?
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    var user: AnyPublisher<User?, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<User?, Never>(nil)
    
    var familyMembers: AnyPublisher<[DecentrailizedUser]?, Never> {
        _familyMembers.eraseToAnyPublisher()
    }
    private let _familyMembers = CurrentValueSubject<[DecentrailizedUser]?, Never>(nil)
    
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
            LogUtil.log("From HouseholdRepository -- household -- \(household)")
            
            if let household = household, !household.id.isEmpty {
                LogUtil.log("Received valid household, reading members")
                self?.readFamilyMembersInHousehold(withHouseholdId: household.id)
            }
        }
        .store(in: &cancellables)
    }
    
    func readFamilyMember(withId lookUpId: String) throws -> DecentrailizedUser? {
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
    
    func reset() {
        
    }
}

class UserMockService: UserService {
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    var user: AnyPublisher<User?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    var familyMembers: AnyPublisher<[DecentrailizedUser]?, Never> {
        Just (
            [.mock, .mock, .mock]
        )
        .eraseToAnyPublisher()
    }
    
    func readFamilyMember(withId lookUpId: String) async throws -> DecentrailizedUser? {return .mock}
}
