
//  AddChoreViewModel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import Combine
import UIKit
import FirebaseFirestore

enum CreateChoreViewModelError: Error, LocalizedError {
    case missingName
    case invalidAmount
    case missingDescription
    case noCurrentUser
    
    var errorDescription: String? {
        switch self {
            case .missingName:
                return "Please enter a name for this task."
            case .invalidAmount:
                return "Please enter a valid reward amount for this task."
            case .missingDescription:
                return "Please enter a description for this task."
            case .noCurrentUser:
                return "Something went wrong. Please try again later!"
        }
    }
}

class CreateChoreViewModel: ObservableObject {
    @Published var images: [UIImage?] = [nil]
    @Published var createChoreResult: Result<Void, CreateChoreViewModelError>?
    
    var choreName: String?
    var choreDescription: String?
    var choreRewardAmount: String?
    private let userService: UserService
    private let storageService: StorageService
    private let choreService: ChoreService
    private let choreMapper: ChoreMapper
    
    init(
        userService: UserService,
        storageService: StorageService,
        choreService: ChoreService,
        choreMapper: ChoreMapper
    ) {
        self.userService = userService
        self.storageService = storageService
        self.choreService = choreService
        self.choreMapper = choreMapper
    }
    
    func createChore() {
        guard let currentUser = userService.getCurrentUser() else {
            createChoreResult = .failure(.noCurrentUser)
            return
        }
        guard let choreName = choreName, !choreName.isEmpty else {
            createChoreResult = .failure(.missingName)
            return
        }
        guard let choreRewardAmount = choreRewardAmount?.stripDollarSign(),
              choreRewardAmount != StringConstant.emptyString,
              let choreRewardAmountDouble = Double(choreRewardAmount.stripDollarSign()) else {
            createChoreResult = .failure(.invalidAmount)
            return
        }
        guard let choreDescription = choreDescription, !choreDescription.isEmpty else {
            createChoreResult = .failure(.missingDescription)
            return
        }
        
        let currentUserDenorm = DenormalizedUser(
            id: currentUser.id,
            name: currentUser.name,
            profileColor: currentUser.profileColor
        )
        
        Task {
            let imageURLs = try await storageService.uploadImages(images.compactMap{$0})
            let choreImageUrls = imageURLs.map { $0.absoluteString }
            
            let chore = Chore(
                id: UUID().uuidString,
                name: choreName,
                requestor: currentUserDenorm,
                acceptor: nil,
                description: choreDescription,
                rewardAmount: choreRewardAmountDouble,
                imageUrls: choreImageUrls,
                createdDate: "",
                finishedDate: nil,
                actionButtonType: .nothing,
                choreStatus: ""
            )
            
            guard let choreDto = choreMapper.getChoreDTOFrom(chore) else {
                return
            }
            
            await choreService.createChore(from: choreDto)
            
            createChoreResult = .success(())
        }
    }
    
    private func userDetail(withId lookUpId: String?) -> DenormalizedUser? {
        guard let lookUpId = lookUpId,
              let currentUserId = userService.getCurrentUser()?.id
        else {
            return nil
        }
        var userDetail: DenormalizedUser? = nil
        
        if let familyMember = userService.readFamilyMember(withId: lookUpId) {
            if lookUpId == currentUserId {
                userDetail = .init(id: familyMember.id, name: "You", profileColor: familyMember.profileColor)
            }
            else {
                userDetail = familyMember
            }
        }
        
        return userDetail
    }
    
    func add(image: UIImage) {
        images.insert(image, at: 0)
    }
}

extension Dependency.ViewModel {
    func addChoreViewModel() -> CreateChoreViewModel {
        return CreateChoreViewModel(
            userService: service.userService,
            storageService: service.storageService,
            choreService: service.choreService,
            choreMapper: mapper.choreMapper
        )
    }
}
