//
//  ProfileViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class MenuViewModel {
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signOut() {
        authService.signOut()
    }
}

extension Dependency.ViewModel {
    func menuViewModel() -> MenuViewModel {
        return MenuViewModel(authService: service.authService)
    }
}
