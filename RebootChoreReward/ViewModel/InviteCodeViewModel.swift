
//  InviteCodeViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import Combine

class InviteCodeViewModel: ObservableObject {
    @Published var shouldNavigateToCreateProfileVC: Bool = false
    
    var inviteCode: String?

    private var cancellables: Set<AnyCancellable> = []
    private let householdService: HouseholdService
    private let inviteCodeService: InviteCodeService
    
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
            if let household = household {
                self?.shouldNavigateToCreateProfileVC = true
            }
        }
        .store(in: &cancellables)
    }
    
    func readInviteCode(completion: @escaping (String?)-> Void) {
        guard let inviteCode = inviteCode else {
            completion("Please enter the invite code.")
            return
        }
        
        Task {
            do {
                try await inviteCodeService.readInviteCode(inviteCode)
                completion(nil)
            }
            catch {
                completion("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension Dependency.ViewModel {
    func inviteCodeViewModel() -> InviteCodeViewModel {
        return InviteCodeViewModel(
            householdService: service.householdService,
            inviteCodeService: service.inviteCodeService
        )
    }
}
