
//  AddHouseholdMemberViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import Combine
import Foundation

class AddHouseholdMemberViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private var householdService: HouseholdService
    
    private var currentHouseholdId: String? = nil
    
    init(
        householdService: HouseholdService
    ) {
        self.householdService = householdService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("From HouseholdService -- household -- \(household)")
            self?.currentHouseholdId = household?.id
        }
        .store(in: &cancellables)
    }
    
    func getInviteLink() -> String? {
        guard let currentHouseholdId = currentHouseholdId else {
            return nil
        }
        
        return "https://get-taskie.app/invite/\(currentHouseholdId)"
    }
}

extension Dependency.ViewModel {
    func addHouseholdMemberViewModel() -> AddHouseholdMemberViewModel {
        return AddHouseholdMemberViewModel(
            householdService: service.householdService
        )
    }
}
