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
    private var currentUserCache: [String: String] = [:]
    private let _isUserLoggedIn = PassthroughSubject<Bool, Never>()
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    
    init() {
        // Initialize with the current auth state
        _isUserLoggedIn.send(Auth.auth().currentUser != nil)
        
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.updateCurrentUserCache(user: user)
            self?._isUserLoggedIn.send(user != nil)
        }
    }
    
    func signUp(withEmail email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func logIn(withEmail email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func getCurrentUserCache(key: String) -> String? {
        return currentUserCache[key]
    }
    
    private func updateCurrentUserCache(user: FirebaseAuth.User?) {
        currentUserCache.removeAll()
        guard let user = user else { return }
        currentUserCache["uid"] = user.uid
        currentUserCache["displayName"] = user.displayName
        currentUserCache["photoUrl"] = user.photoURL?.absoluteString
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            clearCurrentUserCache()
        } catch {
            print("Error signing out \(error)")
        }
    }
    
    func clearCurrentUserCache() {
        currentUserCache.removeAll()
    }
}
