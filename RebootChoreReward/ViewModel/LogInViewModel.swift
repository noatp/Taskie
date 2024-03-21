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
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func logIn(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await authService.logIn(withEmail: email, password: password)
                completion(nil)
            } catch {
                completion("Error signing in: \(error.localizedDescription)")
            }
        }
    }
}

extension Dependency.ViewModel {
    func logInViewModel() -> LogInViewModel {
        return LogInViewModel(authService: service.authService)
    }
}
