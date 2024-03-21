//
//  ProfileViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class ProfileViewModel {
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signOut() {
        authService.signOut()
    }
}

extension Dependency.ViewModel {
    func profileViewModel() -> ProfileViewModel {
        return ProfileViewModel(authService: service.authService)
    }
}
