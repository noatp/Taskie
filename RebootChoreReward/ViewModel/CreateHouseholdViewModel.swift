
//  CreateHouseholdViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Combine

class CreateHouseholdViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
}

extension Dependency.ViewModel {
    func createHouseholdViewModel() -> CreateHouseholdViewModel {
        return CreateHouseholdViewModel()
    }
}
