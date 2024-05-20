//
//  AuthService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthServiceError: Error, LocalizedError {
    case missingInput
    case invalidEmailAddress
    case emailAlreadyInUse
    
    var errorDescription: String? {
        switch self {
            case .missingInput:
                return "Please enter all required fields."
            case .invalidEmailAddress:
                return "Please enter a valid email address."
            case .emailAlreadyInUse:
                return "This email is associated with an existing Taskie account. If you already have an account, please log in."
        }
    }
}

protocol AuthService {
    var isUserLoggedIn: AnyPublisher<Bool, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func logIn(withEmail email: String?, password: String?)
    func signUp()
    func signOut()
    func silentLogIn()
    func cacheEmailAddressForSignUp(_ email: String)
    func cachePassowrdForSignUp(_ password: String)
    func getCurrentUserEmail() -> String?
}

class AuthenticationService: AuthService {
    private let auth = Auth.auth()
    private let userRepository: UserRepository
    private let choreRepository: ChoreRepository
    private let householdRepository: HouseholdRepository
    private let invitationRepository: InvitationRepository
    
    private var householdIdFromUniversalLink: String?
    private var emailAddressForSignUp: String?
    private var passwordForSignUp: String?
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    private let _isUserLoggedIn = PassthroughSubject<Bool, Never>()
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    init(
        userRepository: UserRepository,
        choreRepository: ChoreRepository,
        householdRepository: HouseholdRepository,
        invitationRepository: InvitationRepository
    ) {
        self.userRepository = userRepository
        self.choreRepository = choreRepository
        self.householdRepository = householdRepository
        self.invitationRepository = invitationRepository
    }
    
    func logIn(withEmail email: String?, password: String?) {
        guard let email = email,
              let password = password
        else {
            self._error.send(AuthServiceError.missingInput)
            return
        }
        
        auth.signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self._error.send(error)
            }
            else {
                self.checkCurentAuthSession { currentUserId in
                    self.userRepository.readUser(withId: currentUserId)
                }
            }
        }
    }
    
    func signUp() {
        guard let email = emailAddressForSignUp,
              let password = passwordForSignUp
        else {
            self._error.send(AuthServiceError.missingInput)
            return
        }
        
        auth.createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else {
                return
            }
            
            if let error = error as NSError? {
                if error.domain == AuthErrorDomain {
                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self._error.send(AuthServiceError.emailAlreadyInUse)
                        return
                    }
                }
                self._error.send(error)
                return
            }
            else {
                self.checkCurentAuthSession { currentUserId in
                    Task {
                        await self.userRepository.createUser(from: User(name: nil, id: currentUserId, householdId: nil, role: .parent, profileColor: nil))
                        self.userRepository.readUser(withId: currentUserId)
                    }
                }
            }
        }
    }
    
    func silentLogIn() {
        LogUtil.log("Performing silent login")
        auth.currentUser?.getIDTokenForcingRefresh(true){ [weak self] _, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self.signOut()
                LogUtil.log("\(error)")
            }
            else {
                self.checkCurentAuthSession { currentUserId in
                    self.userRepository.readUser(withId: currentUserId)
                }
            }
        }
    }
    
    private func checkCurentAuthSession(afterAuthenticated: (_ currentUserId: String) -> Void) {
        guard let currentUserId = auth.currentUser?.uid else {
            _isUserLoggedIn.send(false)
            LogUtil.log("currentUserId: nil -- resetting UserRepository")
            resetUserRepository()
            return
        }
        LogUtil.log("currentUserId: \(currentUserId)")
        _isUserLoggedIn.send(true)
        afterAuthenticated(currentUserId)
    }
    
    func signOut() {
        do {
            try auth.signOut()
            LogUtil.log("Signing out")
            checkCurentAuthSession { currentUserId in }
        } catch {
            LogUtil.log("Error signing out \(error)")
        }
    }
    
    func cacheEmailAddressForSignUp(_ email: String) {
        self.emailAddressForSignUp = email
    }
    
    func cachePassowrdForSignUp(_ password: String) {
        self.passwordForSignUp = password
    }
    
    func resetUserRepository() {
        userRepository.reset()
    }
    
    func getCurrentUserEmail() -> String? {
        return auth.currentUser?.email
    }
}

class AuthMockService: AuthService {
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    func signUpWithExistingHousehold(householdId: String, withEmail email: String?, password: String?, name: String?) {}
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    func logIn(withEmail email: String?, password: String?) {}
    
    func signUp() {}
    
    func silentLogIn() {}
    
    func signOut() {}
    
    func cacheEmailAddressForSignUp(_ email: String) {}
    
    func cachePassowrdForSignUp(_ password: String) {}
            
    func getCurrentUserEmail() -> String? { return nil }
}
