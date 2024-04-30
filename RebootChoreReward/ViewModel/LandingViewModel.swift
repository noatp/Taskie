
//  LandingViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import Combine

class LandingViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var householdService: HouseholdService
    
    init(householdService: HouseholdService) {
        self.householdService = householdService
    }
}

extension Dependency.ViewModel {
    func landingViewModel() -> LandingViewModel {
        return LandingViewModel(householdService: service.householdService)
    }
}
