
//  AddChoreViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Combine

class AddChoreViewModel: ObservableObject {
    var choreName: String?
    
    func createChore(completion: @escaping (_ errorMessage: String?) -> Void) {
        guard let choreName = choreName, !choreName.isEmpty else {
            completion("Please enter a name for this chore.")
            return
        }
        
        Task {
            do {
                try await ChoreFirestoreService.shared.createChore(withChore: Chore(
                    name: choreName,
                    creator: "Me"
                ))
                completion(nil)
            } catch {
                completion("Error creating chore: \(error)")
            }
        }
    }
}
