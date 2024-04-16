
//  AddHouseholdMemberViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import Combine

class AddHouseholdMemberViewModel: ObservableObject {
    @Published var inviteCode: String = ""
    @Published var shouldShowRetryButton: Bool = false
     
    private var cancellables: Set<AnyCancellable> = []
    private var householdService: HouseholdService
    
    init(householdService: HouseholdService) {
        self.householdService = householdService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("Received household \(household)")

            if let inviteCode = household.inviteCode {
                self?.inviteCode = inviteCode
            }
            else {
                self?.generateInviteCode()
            }
        }
        .store(in: &cancellables)
    }
    
    func generateInviteCode() {
        householdService.requestInviteCode { [weak self] success in
            self?.shouldShowRetryButton = !success
        }
    }
}

extension Dependency.ViewModel {
    func addHouseholdMemberViewModel() -> AddHouseholdMemberViewModel {
        return AddHouseholdMemberViewModel(householdService: service.householdService)
    }
}
