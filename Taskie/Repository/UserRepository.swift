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
    case updatingError
}

class UserRepository {
    private let db = Firestore.firestore()
    private var householdMemberCollectionListener: ListenerRegistration?
    private var userDocumentListener: ListenerRegistration?
    
    var members: AnyPublisher<[DecentrailizedUser]?, Never> {
        _members.eraseToAnyPublisher()
    }
    private let _members = CurrentValueSubject<[DecentrailizedUser]?, Never>(nil)
    
    var user: AnyPublisher<User?, Never> {
        _user.eraseToAnyPublisher()
    }
    private let _user = CurrentValueSubject<User?, Never>(nil)
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    func createUser(from userObject: User) async {
        let userDocRef = db.collection("users").document(userObject.id)
        
        do {
            try await userDocRef.setDataAsync(from: userObject)
        } catch {
            LogUtil.log("Error creating user: \(error.localizedDescription)")
            self._error.send(error)
        }
    }
    
    func createUserInHouseholdSub(householdId: String, withUser decentralizedUserObject: DecentrailizedUser) async {
        let userDocRef = db.collection("households").document(householdId).collection("users").document(decentralizedUserObject.id)
        
        do {
            try await userDocRef.setDataAsync(from: decentralizedUserObject)
        }
        catch {
            LogUtil.log("Error creating user: \(error.localizedDescription)")
            self._error.send(error)
        }
    }
    
    func readUser(withId userId: String) {
        let userDocRef = db.collection("users").document(userId)
        self.userDocumentListener = userDocRef.addSnapshotListener { [weak self] userDocSnapshot, error in
            guard let userDoc = userDocSnapshot else {
                LogUtil.log("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                self?._error.send(error)
                return
            }
            
            do {
                let user = try userDoc.data(as: User.self)
                self?._user.send(user)
            } catch {
                LogUtil.log("Error decoding document: \(error.localizedDescription)")
                self?._error.send(error)
            }
        }
    }
    
    func readMembers(inHousehold householdId: String) {
        let householdMemberCollectionRef = db.collection("households").document(householdId).collection("users")
        self.householdMemberCollectionListener = householdMemberCollectionRef
        //.orderByage
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                        self?._error.send(error)
                    }
                    return
                }
                
                let members = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: DecentrailizedUser.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        self?._error.send(error)
                        return nil
                    }
                }
                
                self?._members.send(members)
            }
    }
    
    func updateUser(atUserId userId: String, withHouseholdId householdId: String) async {
        let userDocRef = db.collection("users").document(userId)
        
        do {
            try await userDocRef.updateData(["householdId": householdId])
        } catch {
            LogUtil.log("Error updating user household ID: \(error.localizedDescription)")
            self._error.send(error)
        }
    }
    
    func reset() {
        LogUtil.log("UserRepository -- resetting")
        householdMemberCollectionListener?.remove()
        householdMemberCollectionListener = nil
        userDocumentListener?.remove()
        userDocumentListener = nil
        _members.send(nil)
        _user.send(nil)
        _error.send(nil)
    }
    
    deinit {
        householdMemberCollectionListener?.remove()
        userDocumentListener?.remove()
    }
}
