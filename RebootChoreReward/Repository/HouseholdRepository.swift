//
//  HouseholdRepository.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/18/24.
//

import FirebaseFirestore
import Combine

enum HouseholdRepositoryError: Error {
    case householdNotFound
    case encodingError
    case fetchingError
    case decodingError
    case creatingError
    case queryingError
}

class HouseholdRepository {
    private let db = Firestore.firestore()
    private var householdDocumentListener: ListenerRegistration?
    var household: AnyPublisher<(Household?, Error?), Never> {
        _household.eraseToAnyPublisher()
    }
    private let _household = CurrentValueSubject<(Household?, Error?), Never>((nil, nil))
        
    func createHousehold(from householdObject: Household) async {
        let householdDocRef = db.collection("households").document(householdObject.id)
        
        do {
            try await householdDocRef.setDataAsync(from: householdObject)
        }
        catch {
            LogUtil.log("Error encoding household: \(error.localizedDescription)")
            self._household.send((nil, HouseholdRepositoryError.encodingError))
        }
    }
    
    func readHousehold(withId householdId: String) {
        let householdDocRef = db.collection("households").document(householdId)
        self.householdDocumentListener = householdDocRef.addSnapshotListener { [weak self] householdDocSnapshot, error in
            guard let householdDoc = householdDocSnapshot else {
                LogUtil.log("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                self?._household.send((nil, HouseholdRepositoryError.fetchingError))
                return
            }
            
            do {
                let household = try householdDoc.data(as: Household.self)
                self?._household.send((household, nil))
            } catch {
                LogUtil.log("Error decoding document: \(error.localizedDescription)")
                self?._household.send((nil, HouseholdRepositoryError.decodingError))
            }
        }
    }
    
    func readHouseholdTagForCollsion(tag: String) async throws-> Bool {
        let householdCollectionRef = db.collection("households")
        
        let querySnapshot = try await householdCollectionRef.whereField("tag", isEqualTo: tag).getDocuments()
        if querySnapshot.documents.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    func readHouseholdIdFromInvitation(withEmail email: String) async throws -> String? {
        let docRef = db.collection("invitations").document(email)
        let document = try await docRef.getDocument()
        if let data = document.data(),
           let householdId = data["householdId"] as? String {
            return householdId
        }
        else {
            return nil
        }
    }
    
    func reset() {
        LogUtil.log("HouseholdRepository -- resetting")
        householdDocumentListener?.remove()
        householdDocumentListener = nil
        _household.send((nil, nil))
    }
    
    deinit {
        householdDocumentListener?.remove()
    }
}
