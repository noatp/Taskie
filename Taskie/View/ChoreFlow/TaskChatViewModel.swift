
//  TaskChatViewModel.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Combine

class TaskChatViewModel: ObservableObject {
    @Published var choreDetail: Chore?
    @Published var chatMessages: [ChatMessage] = []
    private var cancellables: Set<AnyCancellable> = []
    private let choreService: ChoreService
    private let userService: UserService
    private let chatMessageService: ChatMessageService
    private let chatMessageMapper: ChatMessageMapper
    private let choreMapper: ChoreMapper
    
    init(
        userService: UserService,
        choreService: ChoreService,
        chatMessageService: ChatMessageService,
        chatMessageMapper: ChatMessageMapper,
        choreMapper: ChoreMapper
    ) {
        self.choreService = choreService
        self.userService = userService
        self.chatMessageService = chatMessageService
        self.chatMessageMapper = chatMessageMapper
        self.choreMapper = choreMapper
        subscribeToChoreService()
        subscribeToChatMessageService()
    }
    
    private func subscribeToChoreService() {
        choreService.selectedChore.sink { [weak self] choreDto in
            guard let choreDto = choreDto else {
                return
            }
            self?.chatMessageService.readChatMessages(ofChore: choreDto.id)
            self?.choreDetail = self?.choreMapper.getChoreFrom(choreDto)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToChatMessageService() {
        chatMessageService.chatMessages.sink { [weak self] chatMessagesDto in
            guard let chatMessagesDto = chatMessagesDto,
                  let self = self
            else {
                return
            }
            self.chatMessages = chatMessagesDto.compactMap { self.chatMessageMapper.getChatMessageFrom($0) }
        }
        .store(in: &cancellables)
    }
    
    private func createNewMessage(_ message: String) {
        guard let currentUserId = userService.getCurrentUser()?.id,
              let currentChoreId = choreDetail?.id
        else {
            return
        }
        
        Task {
            await chatMessageService.createNewMessage(
                message,
                byUserId: currentUserId,
                atChoreId: currentChoreId
            )
        }
    }
}

extension Dependency.ViewModel {
    func taskChatViewModel() -> TaskChatViewModel {
        return TaskChatViewModel(
            userService: service.userService,
            choreService: service.choreService,
            chatMessageService: service.chatMessageService,
            chatMessageMapper: mapper.chatMessageMapper, 
            choreMapper: mapper.choreMapper
        )
    }
}
