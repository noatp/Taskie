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
    
    func logIn(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await AuthService.shared.logIn(withEmail: email, password: password)
                completion(nil)
            } catch {
                completion("Error signing in: \(error.localizedDescription)")
            }
        }
    }
}
