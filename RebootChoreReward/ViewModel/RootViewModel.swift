//
//  RootViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var authState: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    private var authService: AuthService
    
    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        subscribeToAuthService()
    }
    
    private func subscribeToAuthService() {
        authService.isUserLoggedIn.sink { [weak self] isUserLoggedIn in
            self?.authState = isUserLoggedIn
        }
        .store(in: &cancellables)
    }
}
