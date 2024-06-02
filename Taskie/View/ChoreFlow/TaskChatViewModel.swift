
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
    private let chatMessageService: ChatMessageService
    
    init(
        choreService: ChoreService,
        chatMessageService: ChatMessageService
    ) {
        self.choreService = choreService
        self.chatMessageService = chatMessageService
        subscribeToChoreService()
        subscribeToChatMessageService()
    }
    
    private func subscribeToChoreService() {
        choreService.selectedChore.sink { [weak self] choreDto in
            guard let choreDto = choreDto else {
                return
            }
            self?.chatMessageService.readChatMessages(ofChore: choreDto.id)
//            self?.choreDetail = self?.choreMapper.getChoreFrom(choreDto)
        }
        .store(in: &cancellables)
    }
    
    private func subscribeToChatMessageService() {
        chatMessageService.chatMessages.sink { [weak self] chatMessages in
            guard let chatMessages = chatMessages else {
                return
            }
            LogUtil.log("From ChatMessageService -- chatMessages -- \(chatMessages)")
            self?.chatMessages = chatMessages
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func taskChatViewModel() -> TaskChatViewModel {
        return TaskChatViewModel(choreService: service.choreService, chatMessageService: service.chatMessageService)
    }
}
