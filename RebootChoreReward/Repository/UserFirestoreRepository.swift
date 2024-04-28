//
//  UserFirestoreRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum UserRepositoryError: Error {
    case userNotFound
    case encodingError
}

class UserFirestoreRepository {
    private let db = Firestore.firestore()
    private var householdMemberCollectionListener: ListenerRegistration?
    private var userDocumentListener: ListenerRegistration?
    private var householdMemberCollectionRef: CollectionReference?
    
    var members: AnyPublisher<[User]?, Never> {
        _members.eraseToAnyPublisher()
    }
    private let _members = CurrentValueSubject<[User]?, Never>(nil)
    
    var userHouseholdId: AnyPublisher<String?, Never> {
        _userHouseholdId.eraseToAnyPublisher()
    }
    private let _userHouseholdId = CurrentValueSubject<String?, Never>(nil)
    
    init() {}
    
    func createUser(from userObject: User, inHousehold householdId: String) async throws {
        householdMemberCollectionRef = db.collection("households").document(householdId).collection("members")
        do {
            guard let documentData = try CodableUtil.dictionaryFromCodable(userObject) else {
                throw UserRepositoryError.encodingError
            }
            try await householdMemberCollectionRef?.document(userObject.id).setData(documentData)
            try await db.collection("users").document(userObject.id).setData(["householdId": householdId])
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
        LogUtil.log("attaching listener for userId \(userId)")
        userDocumentListener = db.collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                if let error = error {
                    LogUtil.log("Error: \(error.localizedDescription)")
                    self?._userHouseholdId.send(nil)
                    return
                }
                
                guard let document = documentSnapshot else {
                    LogUtil.log("Error fetching document")
                    self?._userHouseholdId.send(nil)
                    return
                }
                
                guard let data = document.data() else {
                    LogUtil.log("Document data was empty")
                    self?._userHouseholdId.send(nil)
                    return
                }
                
                guard let householdId = data["householdId"] as? String else {
                    LogUtil.log("Failed to get householdId as String")
                    self?._userHouseholdId.send(nil)
                    return
                }
                
                LogUtil.log("Got householdId \(householdId)")
                self?._userHouseholdId.send(householdId)
            }
    }
    
    func currentHouseholdId() -> String? {
        _userHouseholdId.value
    }
    
    func reset() {
        LogUtil.log("resetting")
        householdMemberCollectionListener?.remove()
        householdMemberCollectionListener = nil
        userDocumentListener?.remove()
        userDocumentListener = nil
        householdMemberCollectionRef = nil
        _members.send([])
        _userHouseholdId.send("")
    }
    
    deinit {
        householdMemberCollectionListener?.remove()
        userDocumentListener?.remove()
    }
}
