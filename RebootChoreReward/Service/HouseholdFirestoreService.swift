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
    var household: AnyPublisher<(Household?, Error?), Never> { get }
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> { get }
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
    
    var household: AnyPublisher<(Household?, Error?), Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<(Household?, Error?), Never>((nil, nil))
    
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
        householdRepository.household.sink { [weak self] (household, error) in
            LogUtil.log("From HouseholdRepository -- (household, error) -- \((household, error))")
            self?._household.send((household, error))
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToUserRepository() {
        userRepository.user.sink { [weak self] (user, _) in
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
            self._household.send((nil, HouseholdServiceError.missingInput))
            return
        }
        
        Task {
            do {
                let hasTagCollision = try await householdRepository.readHouseholdTagForCollsion(tag: tag)
                if hasTagCollision {
                    self._household.send((nil, HouseholdServiceError.tagCollion))
                    return
                }
                let householdId = UUID().uuidString
                let householdObject = Household(id: householdId, tag: tag)
                
                await householdRepository.createHousehold(from: householdObject)
                await userRepository.createUserInHouseholdSub(householdId: householdId, withUser: decentralizedUserObject)
                await userRepository.updateUser(atUserId: decentralizedUserObject.id, withHouseholdId: householdId)
            }
            catch {
                self._household.send((nil, error))
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
    func createHousehold(forUser decentralizedUserObject: DecentrailizedUser, withHouseholdTag tag: String?) {}
    
    func readHouseholdIdFromInvitation(withEmail email: String) async -> String?{ return nil }
    
    func sendHouseholdIdReceivedFromLink(householdId: String) {}
    
    var householdIdReceivedFromLink: AnyPublisher<String?, Never> {
        Just("").eraseToAnyPublisher()
    }
    
    func resetHouseholdIdReceivedFromLink() {}
    
    var household: AnyPublisher<(Household?, Error?), Never>{
        Just(
            (.mock, nil)
        )
        .eraseToAnyPublisher()
    }
    
    func readHousehold(withId householdId: String) {}
}
