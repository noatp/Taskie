
//  ChoreDetailViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import Combine
import FirebaseFirestoreInternal

struct ChoreDetailForView {
    static let empty = ChoreDetailForView(name: "", creatorName: "", description: "", rewardAmount: 0.0, imageUrls: [], createdDate: "")
    let name: String
    let creatorName: String
    let description: String
    let rewardAmount: Double
    let imageUrls: [String]
    let createdDate: String
}


class ChoreDetailViewModel: ObservableObject {
    @Published var choreDetailForView: ChoreDetailForView = .empty
    private var cancellables: Set<AnyCancellable> = []
    private var choreService: ChoreService
    private var userService: UserService
    
    init(
        choreService: ChoreService,
        userService: UserService
    ) {
        self.choreService = choreService
        self.userService = userService
        subscribeToChoreFirestoreService()
    }
    
    private func subscribeToChoreFirestoreService() {
        choreService.selectedChore.sink { [weak self] chore in
            LogUtil.log("From ChoreService -- chore -- \(chore)")
            guard let chore = chore else {
                return
            }
            self?.updateChoreDetail(chore: chore)
        }
        .store(in: &cancellables)
    }
    
    private func updateChoreDetail(chore: Chore) {
        Task {
            do {
                let familyMember = try await getFamilyMember(withId: chore.creator)
                DispatchQueue.main.async { [weak self] in
                    self?.choreDetailForView = ChoreDetailForView(
                        name: chore.name,
                        creatorName: familyMember.name,
                        description: chore.description,
                        rewardAmount: chore.rewardAmount,
                        imageUrls: chore.imageUrls,
                        createdDate: chore.createdDate.toRelativeString())
                }
            } catch {
                LogUtil.log("Failed to fetch family member: \(error)")
            }
        }
    }
    
    
    func getFamilyMember(withId lookUpId: String) async throws -> User {
        return try await userService.readFamilyMember(withId: lookUpId)
    }
}

extension Dependency.ViewModel {
    func choreDetailViewModel() -> ChoreDetailViewModel {
        return ChoreDetailViewModel(choreService: service.choreService, userService: service.userService)
    }
}
