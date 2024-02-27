//
//  ChoreFirestoreService.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class ChoreFirestoreService {
    let db = Firestore.firestore()
    
    func createChore(withChore choreObject: Chore) async throws {
        // Convert User instance to JSON data
        let jsonData = try JSONEncoder().encode(choreObject)
        
        // Convert JSON data to dictionary
        let choreData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        
        do {
            let _ = try await db.collection("chores").addDocument(data: choreData)
            print("Document added")
        } catch let error {
            // Handle any errors
            throw error
        }
    }
}
