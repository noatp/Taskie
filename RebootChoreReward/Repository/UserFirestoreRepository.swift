//
//  UserFirestoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum UserFetchingError: Error {
    case userNotFound
}

class UserFirestoreRepository {
    private let db = Firestore.firestore()
    private var householdMemberCollectionListener: ListenerRegistration?
    private var householdMemberCollectionRef: CollectionReference?

    
    var members: AnyPublisher<[User], Never> {
        _members.eraseToAnyPublisher()
    }
    private let _members = CurrentValueSubject<[User], Never>([])
    
    var userHouseholdId: AnyPublisher<String, Never> {
        _userHouseholdId.eraseToAnyPublisher()
    }
    private let _userHouseholdId = CurrentValueSubject<String, Never>("")
    
    init() {}
    
    func createUser(from userObject: User, inHousehold householdId: String) {
        householdMemberCollectionRef = db.collection("households").document(householdId).collection("members")
        do {
            try householdMemberCollectionRef?.document(userObject.id).setData(from: userObject)
            db.collection("users").document(userObject.id).setData(["householdId": householdId])
        }
        catch let error {
            LogUtil.log("Error writing user to Firestore: \(error)")
        }
    }
    
    func readUsers(inHousehold householdId: String){
        householdMemberCollectionRef = db.collection("households").document(householdId).collection("members")
        self.householdMemberCollectionListener = householdMemberCollectionRef?
            //.orderByage
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                    }
                    return
                }
                
                let members = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: User.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        return nil
                    }
                }
                
                self?._members.send(members)
            }
    }
    
    func readUserForHouseholdId(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] documentSnapshot, error in
            if let error = error {
                LogUtil.log("\(error)")
                return
            }
            else {
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    guard let data = documentSnapshot.data(),
                          let householdId = data["householdId"] as? String else {
                        LogUtil.log("Document does not exist or householdId field is missing")
                        return
                    }
                    self?._userHouseholdId.send(householdId)
                }
                else {
                    LogUtil.log("Document does not exist")
                }
            }
        }
    }
    
    deinit {
        householdMemberCollectionListener?.remove()
    }
}
