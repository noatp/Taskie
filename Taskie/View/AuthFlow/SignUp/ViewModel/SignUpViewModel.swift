//
//  SignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

enum SignUpViewModelError: Error, LocalizedError {
    case invalidEmailAddress
    case invalidPassword
    case invalidPasswordLessThanEight
    case invalidPasswordUpperCase
    case invalidPasswordLowerCase
    
    var errorDescription: String? {
        switch self {
            case .invalidEmailAddress:
                return "Please enter a valid email address."
            case .invalidPassword:
                return "Please enter a valid password."
            case .invalidPasswordLessThanEight:
                return "Password must be at least 8 characters."
            case .invalidPasswordUpperCase:
                return "Password must have at least one uppercase letter."
            case .invalidPasswordLowerCase:
                return "Password must have at least one lowercase letter."
        }
    }
}

class SignUpViewModel: ObservableObject {
    @Published var signUpResult: Result<Void, SignUpViewModelError>?
        
    private var authService: AuthService
    private var userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authService: AuthService,
        userService: UserService
        
    ) {
        self.authService = authService
        self.userService = userService
    }
    
    func checkEmailForSignUp(_ email: String?){
        guard let email = email, !email.isEmpty else {
            self.signUpResult = .failure(.invalidEmailAddress)
            return
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        
        if isValid {
            authService.cacheEmailAddressForSignUp(email)
            self.signUpResult = .success(())
        }
        else {
            self.signUpResult = .failure(.invalidEmailAddress)
        }
    }
    
    func checkPasswordForSignUp(_ password: String?) {
        guard let password = password, !password.isEmpty else {
            self.signUpResult = .failure(.invalidPassword)
            return
        }
        
        guard password.count >= 8 else {
            self.signUpResult = .failure(.invalidPasswordLessThanEight)
            return
        }
        
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else {
            self.signUpResult = .failure(.invalidPasswordUpperCase)
            return
        }
        
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else {
            self.signUpResult = .failure(.invalidPasswordLowerCase)
            return
        }
        
        authService.cachePassowrdForSignUp(password)
        self.signUp()
        self.signUpResult = .success(())
    }
    
    func signUp() {
        self.authService.signUp()
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func signUpViewModel() -> SignUpViewModel {
        return SignUpViewModel(
            authService: service.authService,
            userService: service.userService
        )
    }
}
