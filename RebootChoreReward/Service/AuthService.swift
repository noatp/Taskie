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
    private let auth = Auth.auth()
    
    var isUserLoggedIn: AnyPublisher<Bool, Never> {
        _isUserLoggedIn.eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        auth.currentUser?.uid
    }
    
    init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            LogUtil.log("\(user)")
            self?._isUserLoggedIn.send(user != nil)
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
}
