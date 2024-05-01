//
//  UserRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum UserRepositoryError: Error {
    case userNotFound
    case encodingError
    case fetchingError
    case decodingError
    case creatingError
}

class UserRepository {
    private let db = Firestore.firestore()
    private var householdMemberCollectionListener: ListenerRegistration?
    private var userDocumentListener: ListenerRegistration?
    private var householdMemberCollectionRef: CollectionReference?
    
    var members: AnyPublisher<[User]?, Never> {
        _members.eraseToAnyPublisher()
    }
    private let _members = CurrentValueSubject<[User]?, Never>(nil)
    
    var user: AnyPublisher<(user: User?, error: Error?), Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<(user: User?, error: Error?), Never>((nil, nil))
    
    init() {}
    
    func createUser(from userObject: User) {
        let userDocRef = db.collection("users").document(userObject.id)
        
        do {
            try userDocRef.setData(from: userObject) { [weak self] error in
                if let error = error {
                    LogUtil.log("Error writing document: \(error.localizedDescription)")
                    self?._user.send((nil, UserRepositoryError.creatingError))
                }
            }
            readUser(withId: userObject.id)
        } catch {
            LogUtil.log("Error encoding user: \(error.localizedDescription)")
            self._user.send((nil, UserRepositoryError.encodingError))
        }
    }
    
    func readUser(withId userId: String) {
        let userDocRef = db.collection("users").document(userId)
        self.userDocumentListener = userDocRef.addSnapshotListener { [weak self] userDocSnapshot, error in
            guard let userDoc = userDocSnapshot else {
                LogUtil.log("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                self?._user.send((nil, UserRepositoryError.fetchingError))
                return
            }
            
            do {
                let user = try userDoc.data(as: User.self)
                self?._user.send((user, nil))
            } catch {
                LogUtil.log("Error decoding document: \(error.localizedDescription)")
                self?._user.send((nil, UserRepositoryError.decodingError))
            }
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
                        self?._members.send(nil)
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
    
    //    func readUserForHouseholdId(userId: String) {
    //        LogUtil.log("attaching listener for userId \(userId)")
    //        userDocumentListener = db.collection("users")
    //            .document(userId)
    //            .addSnapshotListener { [weak self] documentSnapshot, error in
    //                if let error = error {
    //                    LogUtil.log("Error: \(error.localizedDescription)")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let document = documentSnapshot else {
    //                    LogUtil.log("Error fetching document")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let data = document.data() else {
    //                    LogUtil.log("Document data was empty")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                guard let householdId = data["householdId"] as? String else {
    //                    LogUtil.log("Failed to get householdId as String")
    //                    self?._userHouseholdId.send(nil)
    //                    return
    //                }
    //
    //                LogUtil.log("Got householdId \(householdId)")
    //                self?._userHouseholdId.send(householdId)
    //            }
    //    }
    
//    func currentHouseholdId() -> String? {
//        _userHouseholdId.value
//    }
    
    func reset() {
        LogUtil.log("UserRepository -- resetting")
        householdMemberCollectionListener?.remove()
        householdMemberCollectionListener = nil
        userDocumentListener?.remove()
        userDocumentListener = nil
        householdMemberCollectionRef = nil
        _members.send(nil)
        _user.send((nil, nil))
    }
    
    deinit {
        householdMemberCollectionListener?.remove()
        userDocumentListener?.remove()
    }
}
