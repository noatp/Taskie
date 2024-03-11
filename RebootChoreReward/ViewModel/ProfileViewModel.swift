//
//  ProfileViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Foundation

class ProfileViewModel {
    func signOut() {
        AuthService.shared.signOut()
    }
}
