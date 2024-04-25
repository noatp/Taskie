
//  InviteCodeViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import Combine

class InviteCodeViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
}

extension Dependency.ViewModel {
    func inviteCodeViewModel() -> InviteCodeViewModel {
        return InviteCodeViewModel()
    }
}
