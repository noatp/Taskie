
//  AddHouseholdMemberViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import Combine
import Foundation

class AddHouseholdMemberViewModel: ObservableObject {
    @Published var inviteCode: String = ""
    @Published var shouldShowRetryButton: Bool = false
     
    private var cancellables: Set<AnyCancellable> = []
    private var householdService: HouseholdService
    private var inviteCodeService: InviteCodeService
    
    init(
        householdService: HouseholdService,
        inviteCodeService: InviteCodeService
    ) {
        self.householdService = householdService
        self.inviteCodeService = inviteCodeService
        subscribeToHouseholdService()
    }
    
    private func subscribeToHouseholdService() {
        householdService.household.sink { [weak self] household in
            LogUtil.log("Received household \(household)")
            
            if let household = household,
               let inviteCode = household.inviteCode,
               let inviteCodeExpirationTime = household.inviteCodeExpirationTime,
               Date.now < inviteCodeExpirationTime.date
            {
                self?.inviteCode = inviteCode
            }
            else {
                self?.inviteCode = ""
                self?.generateInviteCode()
            }
        }
        .store(in: &cancellables)
    }
    
    func generateInviteCode() {
        inviteCodeService.deleteInviteCode { [weak self] _ in
            self?.inviteCodeService.createInviteCode { success in
                self?.shouldShowRetryButton = !success
            }
        }
    }
}

extension Dependency.ViewModel {
    func addHouseholdMemberViewModel() -> AddHouseholdMemberViewModel {
        return AddHouseholdMemberViewModel(
            householdService: service.householdService,
            inviteCodeService: service.inviteCodeService
        )
    }
}
