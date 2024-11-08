//
//  ChatMessageService.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import FirebaseFirestore
import Combine

enum ChatMessageServiceError: Error, LocalizedError {
    case missingInput
    case tagCollion
    
    var errorDescription: String? {
        switch self {
            case .missingInput:
                return "Please enter all required fields."
            case .tagCollion:
                return "This tag already exists. Please use a different tag."
        }
    }
}

protocol ChatMessageService {
    var chatMessages: AnyPublisher<[ChatMessageDTO]?, Never> { get }
    var error: AnyPublisher<Error?, Never> { get }
    func createInitialRequestMessage(from choreObject: ChoreDTO, byUserId currentUserId: String) async
    func createNewMessage(_ message: String, imageUrls: [String], byUserId currentUserId: String, atChoreId choreId: String) async
    func readChatMessages(ofChore choreId: String)
}

class ChatMessageFirestoreService: ChatMessageService {
    private var cancellables: Set<AnyCancellable> = []
    private let choreRepository: ChoreRepository
    private let chatMessageRepository: ChatMessageRepository
    
    var chatMessages: AnyPublisher<[ChatMessageDTO]?, Never> {
        _chatMessages.eraseToAnyPublisher()
    }
    private let _chatMessages = PassthroughSubject<[ChatMessageDTO]?, Never>()
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    init(
        choreRepository: ChoreRepository,
        chatMessageRepository: ChatMessageRepository
    ) {
        self.choreRepository = choreRepository
        self.chatMessageRepository = chatMessageRepository
        subscribeToChatMessageRepository()
    }
    
    private func subscribeToChatMessageRepository() {
        chatMessageRepository.chatMessages.sink { [weak self] chatMessages in
            LogUtil.log("From ChatMesasgeServices -- chatMessages -- \(chatMessages?.count)")
            self?._chatMessages.send(chatMessages)
        }
        .store(in: &cancellables)
    }
    
    func createInitialRequestMessage(from choreObject: ChoreDTO, byUserId currentUserId: String) async {
        guard let choreCollectionRef = choreRepository.getChoreCollectionRef() else {
            return
        }
        await chatMessageRepository.createChatMessage(
            from: ChatMessageDTO(
                id: UUID().uuidString,
                message: "Please help me with \(choreObject.name)\n\n" +
                    "Task description: \(choreObject.description).\n\n" +
                    "You will be rewarded $\(choreObject.rewardAmount.formattedToTwoDecimalPlaces()) upon finishing this task.",
                senderId: currentUserId,
                imageUrls: choreObject.imageUrls,
                sendDate: choreObject.createdDate,
                type: .request
            ),
            forChoreId: choreObject.id,
            inChoreCollectionRef: choreCollectionRef
        )
    }
    
    func createNewMessage(_ message: String, imageUrls: [String], byUserId currentUserId: String, atChoreId choreId: String) async {
        guard let choreCollectionRef = choreRepository.getChoreCollectionRef() else {
            return
        }
        await chatMessageRepository.createChatMessage(
            from: ChatMessageDTO(
                id: UUID().uuidString,
                message: message,
                senderId: currentUserId,
                imageUrls: imageUrls,
                sendDate: .init(),
                type: .normal
            ),
            forChoreId: choreId,
            inChoreCollectionRef: choreCollectionRef
        )
    }
    
    func readChatMessages(ofChore choreId: String) {
        guard let choreCollectionRef = choreRepository.getChoreCollectionRef() else {
            return
        }
        
        chatMessageRepository.readChatMessages(forChore: choreId, inChoreCollectionRef: choreCollectionRef)
    }
}

class ChatMessageMockService: ChatMessageService {
    func createNewMessage(_ message: String, imageUrls: [String], byUserId currentUserId: String, atChoreId choreId: String) async {}
    
    var chatMessages: AnyPublisher<[ChatMessageDTO]?, Never> {
        Just([.mockFromCurrentUserTop, .mockNotFromCurrentUserTop, .mockFromCurrentUserTop, .mockFromCurrentUserTop, .mockNotFromCurrentUserTop]).eraseToAnyPublisher()
    }
    
    var error: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
    
    func createInitialRequestMessage(from choreObject: ChoreDTO, byUserId currentUserId: String) async { }
    
    func readChatMessages(ofChore choreId: String) {}
}
