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
    
    func logIn() {
        self.authService.logIn(withEmail: email, password: password)
    }
}

extension Dependency.ViewModel {
    func logInViewModel() -> LogInViewModel {
        return LogInViewModel(authService: service.authService, userService: service.userService)
    }
}
