
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
    @Published var images: [UIImage] = []
    @Published var isSendingMessage: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let storageService: StorageService
    private let chatMessageService: ChatMessageService
    private let chatMessageMapper: ChatMessageMapper
    private let choreMapper: ChoreMapper
    
    init(
        userService: UserService,
        choreService: ChoreService,
        chatMessageService: ChatMessageService,
        storageService: StorageService,
        chatMessageMapper: ChatMessageMapper,
        choreMapper: ChoreMapper
    ) {
        self.choreService = choreService
        self.userService = userService
        self.chatMessageService = chatMessageService
        self.storageService = storageService
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
            let message = message
            
            await chatMessageService.createNewMessage(
                message,
                imageUrls: imageUrlStrings,
                byUserId: currentUserId,
                atChoreId: currentChoreId
            )
            
            DispatchQueue.main.async {
                self.chatInputText = ""
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
            choreService: service.choreService,
            chatMessageService: service.chatMessageService,
            storageService: service.storageService,
            chatMessageMapper: mapper.chatMessageMapper,
            choreMapper: mapper.choreMapper
        )
    }
}
