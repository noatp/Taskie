//
//  AuthService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import Foundation
import FirebaseAuth
import Combine

class AuthService {    
    private let _isUserLoggedIn = PassthroughSubject<Bool, Never>()
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            user?.getIDTokenForcingRefresh(true) { _, error in
                if let error = error {
                    LogUtil.log("\(error)")
                    self?.signOut()
                }
                else {
                    self?._isUserLoggedIn.send(user != nil)
                }
            }
            
        }
    }
    
    func signUp(withEmail email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func logIn(withEmail email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out \(error)")
        }
    }
}
