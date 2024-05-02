//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/17/24.
//

import Combine
import FirebaseAuth

protocol UserService {
    var user: AnyPublisher<(user: User?, error: Error?), Never> { get }
    var familyMembers: AnyPublisher<(members: [DecentrailizedUser]?, error: Error?), Never> { get }
    func readFamilyMember(withId lookUpId: String) async throws -> DecentrailizedUser
}

class UserFirestoreService: UserService {
    private var cancellables: Set<AnyCancellable> = []
    private let userRepository: UserRepository
    private let householdRepository: HouseholdRepository
    
    var user: AnyPublisher<(user: User?, error: Error?), Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<(user: User?, error: Error?), Never>((nil, nil))
    
    var familyMembers: AnyPublisher<(members: [DecentrailizedUser]?, error: Error?), Never> {
        _familyMembers.eraseToAnyPublisher()
    }
    private let _familyMembers = CurrentValueSubject<(members: [DecentrailizedUser]?, error: Error?), Never>((nil, nil))
    
    
    
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
        userRepository.user.sink { [weak self] (user, error) in
            LogUtil.log("From UserRepository -- (user, error) -- \((user, error))")
            self?._user.send((user, error))
        }
        .store(in: &cancellables)
        
        userRepository.members.sink { [weak self] (members, error) in
            LogUtil.log("From UserRepository -- (members, error) -- \((members, error))")

            self?._familyMembers.send((members, error))
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] (household, _) in
            LogUtil.log("From HouseholdRepository -- household -- \(household)")
            
            if let household = household, !household.id.isEmpty {
                LogUtil.log("Received valid household, reading members")
                self?.readFamilyMembersInHousehold(withHouseholdId: household.id)
            }
        }
        .store(in: &cancellables)
    }
    
    func readFamilyMember(withId lookUpId: String) throws -> DecentrailizedUser {
        if let familyMember = _familyMembers.value.members?.first(where: { $0.id == lookUpId }) {
            return familyMember
        } else {
            throw UserRepositoryError.userNotFound
        }
    }
    
    func readFamilyMembersInHousehold(withHouseholdId householdId: String) {
        userRepository.readMembers(inHousehold: householdId)
    }
    
    func reset() {
        
    }
}

class UserMockService: UserService {
    var user: AnyPublisher<(user: User?, error: Error?), Never> {
        Just(
            (.mock, nil)
        )
        .eraseToAnyPublisher()
    }
    
    var familyMembers: AnyPublisher<(members: [DecentrailizedUser]?, error: Error?), Never> {
        Just (
            ([.mock, .mock, .mock], nil)
        )
        .eraseToAnyPublisher()
    }
    
    func readFamilyMember(withId lookUpId: String) async throws -> DecentrailizedUser {return .mock}
}
