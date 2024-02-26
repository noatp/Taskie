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
    static let shared = AuthService()

    private let _isUserLoggedIn = PassthroughSubject<Bool, Never>()

    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }

    init() {
        // Initialize with the current auth state
        _isUserLoggedIn.send(Auth.auth().currentUser != nil)

        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print(user)
            self?._isUserLoggedIn.send(user != nil)
        }
    }
    
    func signUp(withEmail email: String, password: String) async {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
        catch {
            print("Error signing up: \(error)")
        }
    }
    
    func logIn(withEmail email: String, password: String) async {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
        catch {
            print("Error signing in: \(error)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out \(error)")
        }
    }
}
