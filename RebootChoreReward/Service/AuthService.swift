//
//  AuthService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import Foundation
import FirebaseAuth
import Combine

protocol AuthService {
    var isUserLoggedIn: AnyPublisher<Bool, Never> { get }
    var currentUserId: String? { get }
    func signUp(withEmail email: String, password: String) async throws
    func logIn(withEmail email: String, password: String) async throws
    func signOut()
    func silentLogIn()
}

class AuthenticationService: AuthService {
    private let _isUserLoggedIn = PassthroughSubject<Bool, Never>()
    private let auth = Auth.auth()
    private let userRepository: UserFirestoreRepository
    private let choreRepository: ChoreFirestoreRepository
    private let householdRepository: HouseholdFirestoreRepository

    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    init(
        userRepository: UserFirestoreRepository,
        choreRepository: ChoreFirestoreRepository,
        householdRepository: HouseholdFirestoreRepository
    ) {
        self.userRepository = userRepository
        self.choreRepository = choreRepository
        self.householdRepository = householdRepository
        
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                LogUtil.log("Logged in with userId \(user.uid)")
                self?._isUserLoggedIn.send(true)
            }
            else {
                LogUtil.log("Signed out")
                self?._isUserLoggedIn.send(false)
                self?.resetRepositories()
            }
        }
    }
    
    func signUp(withEmail email: String, password: String) async throws {
        try await auth.createUser(withEmail: email, password: password)
    }
    
    func silentLogIn() {
        auth.currentUser?.getIDTokenForcingRefresh(true){ _, error in
            if let error = error {
                self.signOut()
                LogUtil.log("\(error)")
            }
        }
    }
    
    func logIn(withEmail email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() {
        do {
            try auth.signOut()
            LogUtil.log("Signing out")
        } catch {
            print("Error signing out \(error)")
        }
    }
    
    func resetRepositories() {
        userRepository.reset()
        householdRepository.reset()
        choreRepository.reset()
    }
}

class AuthMockService: AuthService {
    func silentLogIn() {}
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    func signUp(withEmail email: String, password: String) async throws {}
    
    func logIn(withEmail email: String, password: String) async throws {}
    
    func signOut() {}
    
    var currentUserId: String? = ""
    
    
}
