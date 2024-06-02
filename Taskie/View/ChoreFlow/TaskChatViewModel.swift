
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
    private let chatMessageMapper: ChatMessageMapper
    
    init(
        choreService: ChoreService,
        chatMessageService: ChatMessageService,
        chatMessageMapper: ChatMessageMapper
    ) {
        self.choreService = choreService
        self.chatMessageService = chatMessageService
        self.chatMessageMapper = chatMessageMapper
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
        chatMessageService.chatMessages.sink { [weak self] chatMessagesDto in
            guard let chatMessagesDto = chatMessagesDto,
                  let self = self
            else {
                return
            }
            LogUtil.log("From ChatMessageService -- chatMessages -- \(chatMessagesDto)")
            self.chatMessages = chatMessagesDto.compactMap { self.chatMessageMapper.getChatMessageFrom($0) }
        }
        .store(in: &cancellables)
    }
}

extension Dependency.ViewModel {
    func taskChatViewModel() -> TaskChatViewModel {
        return TaskChatViewModel(
            choreService: service.choreService,
            chatMessageService: service.chatMessageService,
            chatMessageMapper: mapper.chatMessageMapper
        )
    }
}
