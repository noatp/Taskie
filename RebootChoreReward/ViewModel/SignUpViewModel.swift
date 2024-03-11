//
//  SignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class SignUpViewModel {
    var email: String?
    var password: String?
    
    func signUp(completion: @escaping (String?) -> Void) {
        guard let email = email, let password = password else {
            completion("Please enter both email and password.")
            return
        }
        
        Task {
            do {
                try await AuthService.shared.signUp(withEmail: email, password: password)
                completion(nil) // Success, no error message to return
            } catch {
                completion("Error signing up: \(error.localizedDescription)")
            }
        }
    }
}
