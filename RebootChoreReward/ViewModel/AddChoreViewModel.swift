
//  AddChoreViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Combine
import UIKit

class AddChoreViewModel: ObservableObject {
    @Published var images: [UIImage?] = [nil]
    var choreName: String?
    var choreDescription: String?
    var choreRewardAmount: String?
    
    func createChore(completion: @escaping (_ errorMessage: String?) -> Void) {
        guard let choreName = choreName, !choreName.isEmpty else {
            completion("Please enter a name for this chore.")
            return
        }
        guard let choreRewardAmount = choreRewardAmount?.stripDollarSign(),
              choreRewardAmount != StringConstant.emptyString,
              let choreRewardAmountDouble = Double(choreRewardAmount.stripDollarSign()) else {
            completion("Please enter a reward amount for this chore.")
            return
        }
        guard let choreDescription = choreDescription else {
            completion(StringConstant.emptyString)
            return
        }
        
        guard let uid = AuthService.shared.getCurrentUserCache(key: "uid") else {
            completion("Something went wrong. Please try again later!")
            return
        }
        
        Task {
            do {
                try await ChoreFirestoreService.shared.createChore(withChore: Chore(
                    name: choreName,
                    creator: uid, 
                    description: choreDescription,
                    rewardAmount: choreRewardAmountDouble
                ))
                completion(nil)
            } catch {
                completion("Error creating chore: \(error)")
            }
        }
    }
    
    func add(image: UIImage) {
        images.insert(image, at: 0)
    }
}
