
//  TaskChatViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Combine
import UIKit

class TaskChatViewModel: ObservableObject {
    @Published var choreDetail: Chore?
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatInputText: String = ""
    @Published var reviewInputText: String = ""
    @Published var images: [UIImage] = []
    @Published var isSendingMessage: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let householdService: HouseholdService
    private let storageService: StorageService
    private let cloudFunctionService: CloudFunctionService
    private let chatMessageService: ChatMessageService
    private let chatMessageMapper: ChatMessageMapper
    private let choreMapper: ChoreMapper
    
    init(
        userService: UserService,
        householdService: HouseholdService,
        choreService: ChoreService,
        chatMessageService: ChatMessageService,
        storageService: StorageService,
        cloudFunctionService: CloudFunctionService,
        chatMessageMapper: ChatMessageMapper,
        choreMapper: ChoreMapper
    ) {
        self.choreService = choreService
        self.householdService = householdService
        self.userService = userService
        self.chatMessageService = chatMessageService
        self.storageService = storageService
        self.cloudFunctionService = cloudFunctionService
        self.chatMessageMapper = chatMessageMapper
        self.choreMapper = choreMapper
        subscribeToChoreService()
        subscribeToChatMessageService()
    }
    
    private func subscribeToChoreService() {
        choreService.selectedChore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] choreDto in
                guard let choreDto = choreDto else {
                    return
                }
                self?.chatMessageService.readChatMessages(ofChore: choreDto.id)
                self?.choreDetail = self?.choreMapper.getChoreFrom(choreDto)
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToChatMessageService() {
        chatMessageService.chatMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] chatMessagesDto in
                guard let chatMessagesDto = chatMessagesDto,
                      let self = self else {
                    return
                }
                let chatMessages = chatMessagesDto.compactMap {
                    self.chatMessageMapper.getChatMessageFrom($0)
                }
                self.chatMessages = self.groupChatMessages(chatMessages)
            }
            .store(in: &cancellables)
    }
    
    func createNewMessage() {
        guard !chatInputText.isEmpty else {
            return
        }
        handleChatMessageCreation(message: chatInputText)
    }
    
    private func groupChatMessages(_ chatMessages: [ChatMessage]) -> [ChatMessage] {
        var groupedChatMessages = chatMessages
        let count = chatMessages.count
        
        for (index, message) in chatMessages.enumerated() {
            if index == 0 || chatMessages[index - 1].sender.id != message.sender.id {
                groupedChatMessages[index].isFirstInSequence = true
            } else {
                groupedChatMessages[index].isFirstInSequence = false
            }
            
            if index == count - 1 || chatMessages[index + 1].sender.id != message.sender.id {
                groupedChatMessages[index].isLastInSequence = true
            } else {
                groupedChatMessages[index].isLastInSequence = false
            }
        }
        
        return groupedChatMessages
    }
    
    private func handleChatMessageCreation(message: String) {
        guard let currentUserId = userService.getCurrentUser()?.id,
              let currentChoreId = choreDetail?.id
        else {
            return
        }
        
        Task {
            DispatchQueue.main.async {
                self.isSendingMessage = true
            }
            let imageURLs = try await storageService.uploadImages(images.map{$0})
            let imageUrlStrings = imageURLs.map { $0.absoluteString }
            
            await chatMessageService.createNewMessage(
                message,
                imageUrls: imageUrlStrings,
                byUserId: currentUserId,
                atChoreId: currentChoreId
            )
            
            DispatchQueue.main.async {
                self.chatInputText = ""
                self.reviewInputText = ""
                self.images = []
                self.isSendingMessage = false
            }
        }
    }
    
    func acceptSelectedChore() {
        guard let currentUserId = userService.getCurrentUser()?.id else {
            return
        }
        handleChatMessageCreation(message: "I will help you!")
        choreService.acceptSelectedChore(acceptorId: currentUserId)
    }
    
    func finishedSelectedChore() {
//        choreService.finishedSelectedChore()
        handleChatMessageCreation(message: "I finished this chore! Take a look at the attached photos.")
        choreService.makeSelectedChoreReadyForReview()
    }
    
    func approveFinishedChore() {
        choreService.finishedSelectedChore()
        if reviewInputText.isEmpty {
            handleChatMessageCreation(message: "Well done! Thank you very much! You will receive your reward!")
        }
        else {
            handleChatMessageCreation(message: reviewInputText)
        }
        choreService.makeSelectedChoreNotReadyForReview()
        guard let householdId = householdService.getCurrentHousehold()?.id,
              let choreId = choreDetail?.id
        else {
            return
        }
        cloudFunctionService.addRewardToUserBalance(householdId: householdId, choreId: choreId)
    }
    
    func denyFinishedChore() {
        if reviewInputText.isEmpty {
            handleChatMessageCreation(message: "I am not happy with the result...")
        }
        else {
            handleChatMessageCreation(message: reviewInputText)
        }
        choreService.makeSelectedChoreNotReadyForReview()
    }
    
    func withdrawSelectedChore() {
        choreService.withdrawSelectedChore()
    }
    
    func removeImage(image: UIImage) {
        if let index = images.firstIndex(of: image) {
            images.remove(at: index)
        }
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension Dependency.ViewModel {
    func taskChatViewModel() -> TaskChatViewModel {
        return TaskChatViewModel(
            userService: service.userService,
            householdService: service.householdService,
            choreService: service.choreService,
            chatMessageService: service.chatMessageService,
            storageService: service.storageService,
            cloudFunctionService: service.cloudFunctionService,
            chatMessageMapper: mapper.chatMessageMapper,
            choreMapper: mapper.choreMapper
        )
    }
}
