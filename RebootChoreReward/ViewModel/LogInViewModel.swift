//
//  LogInViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class LogInViewModel {
    var email: String?
    var password: String?
    private let authService: AuthService
    private let userService: UserService
    
    init(
        authService: AuthService,
        userService: UserService
    ) {
        self.authService = authService
        self.userService = userService
    }
    
    func logIn(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await self.authService.logIn(withEmail: email, password: password)
                guard let currentUserId = self.authService.currentUserId else {
                    completion("Error signing in: could not get user info")
                    return
                }
                completion(nil)
            } catch {
                completion("Error signing in: \(error.localizedDescription)")
            }
        }
    }
}

extension Dependency.ViewModel {
    func logInViewModel() -> LogInViewModel {
        return LogInViewModel(authService: service.authService, userService: service.userService)
    }
}
