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
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?)
    func readHousehold(withId householdId: String)
    func sendHouseholdIdReceivedFromLink(householdId: String)
    func resetHouseholdIdReceivedFromLink()
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?
}

class HouseholdFirestoreService: HouseholdService {
    private var cancellables: Set<AnyCancellable> = []
    private var householdRepository: HouseholdRepository
    private var userRepository: UserRepository
    
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> {
        _householdIdReceivedFromLink.eraseToAnyPublisher()
    }
    private let _householdIdReceivedFromLink = CurrentValueSubject<String?, Never>(nil)
    
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
        userRepository: UserRepository
    ) {
        self.householdRepository = householdRepository
        self.userRepository = userRepository
        subscribeToHouseholdRepository()
        subscribeToUserRepository()
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
            LogUtil.log("From UserRepository -- user -- \(user)")
            if let user = user,
               let householdId = user.householdId,
               !householdId.isEmpty
            {
                LogUtil.log("Received valid user, reading household")
                self?.readHousehold(withId: householdId)
            }
            else {
                LogUtil.log("Received invalid householdId, resetting HouseholdRepository")
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
    
    func sendHouseholdIdReceivedFromLink(householdId: String) {
        self._householdIdReceivedFromLink.send(householdId)
    }
    
    func resetHouseholdIdReceivedFromLink() {
        self._householdIdReceivedFromLink.send(nil)
    }
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String? {
        do {
            let householdId = try await householdRepository.readHouseholdIdFromInvitation(withEmail: email)
            return householdId
        }
        catch {
            LogUtil.log(error.localizedDescription)
            return nil
        }
    }
}

class HouseholdMockService: HouseholdService {
    
    
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?) {}
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?{ return nil }
    
    func sendHouseholdIdReceivedFromLink(householdId: String) {}
    
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> {
        Just("").eraseToAnyPublisher()
    }
    
    func resetHouseholdIdReceivedFromLink() {}
    
    var household: AnyPublisher<Household?, Never> {
        Just(.mock).eraseToAnyPublisher()
    }
    
    func readHousehold(withId householdId: String) {}
}
