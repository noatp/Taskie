//
//  AuthService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthServiceError: Error {
    case missingInput
    
    var localizedDescription: String {
        switch self {
        case .missingInput:
            return "Please enter all required fields."
        default:
            return "Please try again later."
        }
    }
}

protocol AuthService {
    var isUserLoggedIn: AnyPublisher<(Bool, Error?), Never> { get }
    var currentUserId: String? { get }
    func logIn(withEmail email: String?, password: String?)
    func signUp(withEmail email: String, password: String, name: String)
    func signOut()
    func silentLogIn()
}

class AuthenticationService: AuthService {
    private let _isUserLoggedIn = PassthroughSubject<(Bool, Error?), Never>()
    private let auth = Auth.auth()
    private let userRepository: UserRepository
    private let choreRepository: ChoreRepository
    private let householdRepository: HouseholdRepository
    
    var isUserLoggedIn: AnyPublisher<(Bool, Error?), Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    init(
        userRepository: UserRepository,
        choreRepository: ChoreRepository,
        householdRepository: HouseholdRepository
    ) {
        self.userRepository = userRepository
        self.choreRepository = choreRepository
        self.householdRepository = householdRepository
    }
    
    func logIn(withEmail email: String?, password: String?) {
        guard let email = email,
              let password = password
        else {
            self._isUserLoggedIn.send((false, AuthServiceError.missingInput))
            return
        }
        
        auth.signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self._isUserLoggedIn.send((false, error))
            }
            else {
                self.checkCurentAuthSession { currentUserId in
                    self.userRepository.readUser(withId: currentUserId)
                }
            }
        }
    }
    
    func signUp(withEmail email: String, password: String, name: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self._isUserLoggedIn.send((false, error))
            }
            else {
                self.checkCurentAuthSession { currentUserId in
                    self.userRepository.createUser(from: User(name: name, id: currentUserId, householdId: nil, role: .parent))
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
        guard let currentUserId = currentUserId else {
            _isUserLoggedIn.send((false, nil))
            LogUtil.log("currentUserId: nil -- resetting UserRepository")
            resetUserRepository()
            return
        }
        LogUtil.log("currentUserId: \(currentUserId)")
        _isUserLoggedIn.send((true, nil))
        afterAuthenticated(currentUserId)
    }
    
    
    func signOut() {
        do {
            try auth.signOut()
            LogUtil.log("Signing out")
            checkCurentAuthSession { currentUserId in}
        } catch {
            LogUtil.log("Error signing out \(error)")
        }
    }
    
    func resetUserRepository() {
        userRepository.reset()
    }
}

class AuthMockService: AuthService {
    var isUserLoggedIn: AnyPublisher<(Bool, Error?), Never> {
        Just(
            (true, nil)
        )
        .eraseToAnyPublisher()
    }
    
    func logIn(withEmail email: String?, password: String?) {}
    
    func signUp(withEmail email: String, password: String, name: String) {}
    
    func silentLogIn() {}
    
    func signOut() {}
    
    var currentUserId: String? = ""
    
    
}
