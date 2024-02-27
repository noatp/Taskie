//
//  UserFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore

class UserFirestoreService {
    let db = Firestore.firestore()
    
    func createUser(from userObject: User) {
        do {
            try db.collection("users").document(userObject.userId).setData(from: userObject)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
}
