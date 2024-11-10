
//  UserProfileViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 11/10/24.
//

import Combine

class UserProfileViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
}

extension Dependency.ViewModel {
    func userProfileViewModel() -> UserProfileViewModel {
        return UserProfileViewModel()
    }
}
