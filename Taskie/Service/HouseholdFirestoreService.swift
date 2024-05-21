//
//  HouseholdFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import Combine
import FirebaseFunctions
import FirebaseAuth

enum HouseholdServiceError: Error, LocalizedError {
    case missingInput
    case tagCollion
    
    var errorDescription: String? {
        switch self {
        case .missingInput:
            return "Please enter all required fields."
        case .tagCollion:
            return "This tag already exists. Please use a different tag."
        }
    }
}

protocol HouseholdService {
    var household: AnyPublisher<Household?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?)
    func readHousehold(withId householdId: String)
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?
    func readHouseholdIdFromUniversalLink() -> String?
    func setHouseholdIdFromUniversalLink(householdId: String)
    func getCurrentHousehold() -> Household?
}

class HouseholdFirestoreService: HouseholdService {
    private var householdIdFromUniversalLink: String?
    private var cancellables: Set<AnyCancellable> = []
    private let householdRepository: HouseholdRepository
    private let userRepository: UserRepository
    private let invitationRepository: InvitationRepository
    
    var household: AnyPublisher<Household?, Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<Household?, Never>(nil)
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    init(
        householdRepository: HouseholdRepository,
        userRepository: UserRepository,
        invitationRepository: InvitationRepository
    ) {
        self.householdRepository = householdRepository
        self.userRepository = userRepository
        self.invitationRepository = invitationRepository
        subscribeToUserRepository()
        subscribeToHouseholdRepository()
    }
    
    private func subscribeToHouseholdRepository() {
        householdRepository.household.sink { [weak self] household in
            LogUtil.log("From HouseholdRepository -- household -- \(household)")
            self?._household.send(household)
        }
        .store(in: &cancellables)
        
        householdRepository.error.sink { [weak self] error in
            LogUtil.log("From HouseholdRepository -- error -- \(error)")
            self?._error.send(error)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] user in
            if let user = user,
               let householdId = user.householdId,
               !householdId.isEmpty
            {
                LogUtil.log("From UserRepository -- user -- \(user), reading household")
                self?.readHousehold(withId: householdId)
            }
            else {
                LogUtil.log("From UserRepository -- user -- nil, resetting HouseholdRepository")
                self?.householdRepository.reset()
            }
        }
        .store(in: &cancellables)
    }
    
    
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?) {
        guard let tag = tag, !tag.isEmpty else {
            self._error.send(HouseholdServiceError.missingInput)
            return
        }
        
        Task {
            do {
                let hasTagCollision = try await householdRepository.readHouseholdTagForCollsion(tag: tag)
                if hasTagCollision {
                    self._error.send(HouseholdServiceError.tagCollion)
                    return
                }
                let householdId = UUID().uuidString
                let householdObject = Household(id: householdId, tag: tag)
                
                await householdRepository.createHousehold(from: householdObject)
                await userRepository.createUserInHouseholdSub(householdId: householdId, withUser: decentralizedUserObject)
                await userRepository.updateUser(atUserId: decentralizedUserObject.id, withHouseholdId: householdId)
            }
            catch {
                self._error.send(error)
            }
        }
    }
    
    func readHousehold(withId householdId: String) {
        householdRepository.readHousehold(withId: householdId)
    }
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String? {
        do {
            let householdIdFromInvitation = try await invitationRepository.readInvitationForHouseholdId(withEmail: email)
            if let householdIdFromInvitation = householdIdFromInvitation,
               !householdIdFromInvitation.isEmpty {
                return householdIdFromInvitation
            }
            return nil
        }
        catch {
            self._error.send(error)
            return nil
        }
    }
    
    func readHouseholdIdFromUniversalLink() -> String? {
        return householdIdFromUniversalLink
    }
    
    func setHouseholdIdFromUniversalLink(householdId: String) {
        self.householdIdFromUniversalLink = householdId
    }
    
    func getCurrentHousehold() -> Household? {
        _household.value
    }
}

class HouseholdMockService: HouseholdService {
    func readHouseholdIdFromUniversalLink() -> String? { return nil }
    
    func setHouseholdIdFromUniversalLink(householdId: String) {}

    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?) {}
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?{ return nil }
        
    var household: AnyPublisher<Household?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    func readHousehold(withId householdId: String) {}
    func getCurrentHousehold() -> Household? { return nil }
}
