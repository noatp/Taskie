
//  PreSignUpViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/29/24.
//

import Combine

class PreSignUpViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
}

extension Dependency.ViewModel {
    func preSignUpViewModel() -> PreSignUpViewModel {
        return PreSignUpViewModel()
    }
}
