
//  AddHouseholdMemberViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import Combine
import Foundation

class AddHouseholdMemberViewModel: ObservableObject {
    @Published var shouldShowRetryButton: Bool = false
     
    private var cancellables: Set<AnyCancellable> = []
    private var householdService: HouseholdService
    
    init(
        householdService: HouseholdService
    ) {
        self.householdService = householdService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("From HouseholdService -- household -- \(household)")
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func addHouseholdMemberViewModel() -> AddHouseholdMemberViewModel {
        return AddHouseholdMemberViewModel(
            householdService: service.householdService
        )
    }
}
