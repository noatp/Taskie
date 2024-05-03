
//  CreateOrAddHouseholdViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import Combine

class CreateOrAddHouseholdViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
    }
}

extension Dependency.ViewModel {
    func createOrAddHouseholdViewModel() -> CreateOrAddHouseholdViewModel {
        return CreateOrAddHouseholdViewModel()
    }
}
