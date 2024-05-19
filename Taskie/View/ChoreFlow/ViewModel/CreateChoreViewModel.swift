
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
    private var authService: AuthService
    private var storageService: StorageService
    private var choreService: ChoreService
    
    init(
        authService: AuthService,
        storageService: StorageService,
        choreService: ChoreService
    ) {
        self.authService = authService
        self.storageService = storageService
        self.choreService = choreService
    }
    
    func createChore() {
        guard let uid = authService.currentUserId else {
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
        
        Task {
            let imageURLs = try await storageService.uploadImages(images.compactMap{$0})
            let choreImageUrls = imageURLs.map { $0.absoluteString }
            let choreId = UUID().uuidString
            
            await choreService.createChore(from: Chore(
                id: choreId,
                name: choreName,
                requestorID: uid,
                acceptorID: nil,
                description: choreDescription,
                rewardAmount: choreRewardAmountDouble,
                imageUrls: choreImageUrls,
                createdDate: .init(),
                finishedDate: nil
            ))
            
            createChoreResult = .success(())
        }
    }
    
    func add(image: UIImage) {
        images.insert(image, at: 0)
    }
}

extension Dependency.ViewModel {
    func addChoreViewModel() -> CreateChoreViewModel {
        return CreateChoreViewModel(
            authService: service.authService,
            storageService: service.storageService,
            choreService: service.choreService
        )
    }
}
