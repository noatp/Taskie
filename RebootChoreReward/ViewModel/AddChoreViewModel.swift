
//  AddChoreViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Combine

class AddChoreViewModel: ObservableObject {
    var choreName: String?
    var choreDescription: String?
    
    func createChore(completion: @escaping (_ errorMessage: String?) -> Void) {
        guard let choreName = choreName,
              let choreDescription = choreDescription,
              !choreName.isEmpty else {
            completion("Please enter a name for this chore.")
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
                    description: choreDescription
                ))
                completion(nil)
            } catch {
                completion("Error creating chore: \(error)")
            }
        }
    }
}
