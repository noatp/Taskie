//
//  ChatMessageRepository.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Combine
import FirebaseFirestore

class ChatMessageRepository {
    private let db = Firestore.firestore()
    private var chatMessageCollectionListener: ListenerRegistration?
    private var chatMessageCollectionRef: CollectionReference?
    
    var chatMessages: AnyPublisher<[ChatMessage]?, Never> {
        _chatMessages.eraseToAnyPublisher()
    }
    private let _chatMessages = CurrentValueSubject<[ChatMessage]?, Never>(nil)
    
    var error: AnyPublisher<Error?, Never> {
        _error.eraseToAnyPublisher()
    }
    private let _error = CurrentValueSubject<Error?, Never>(nil)
    
    func createChatMessage(
        from chatMessageObject: ChatMessage,
        forChoreId choreId: String,
        inChoreCollectionRef choreCollectionRef: CollectionReference
    ) async {
        let chatMessageDocRef = choreCollectionRef.document(choreId).collection("chatMessages").document(chatMessageObject.id)
        
        do {
            try await chatMessageDocRef.setDataAsync(from: chatMessageObject)
        }
        catch {
            LogUtil.log("Error writing chatMessage to Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func readChatMessages(
        forChore choreId: String,
        inChoreCollectionRef choreCollectionRef: CollectionReference
    ) {
        chatMessageCollectionRef = choreCollectionRef.document(choreId).collection("chatMessages")
        guard let chatMessageCollectionRef = chatMessageCollectionRef else {
            return
        }
        self.chatMessageCollectionListener = chatMessageCollectionRef
            .order(by: "sendDate", descending: true)
            .addSnapshotListener { [weak self] collectionSnapshot, error in
                guard let collectionSnapshot = collectionSnapshot else {
                    if let error = error {
                        LogUtil.log("\(error)")
                        self?._error.send(nil)
                    }
                    return
                }
                
                let chatMessages = collectionSnapshot.documents.compactMap { documentSnapshot in
                    do {
                        return try documentSnapshot.data(as: ChatMessage.self)
                    }
                    catch {
                        LogUtil.log("\(error)")
                        self?._error.send(error)
                        return nil
                    }
                }
                
                self?._chatMessages.send(chatMessages)
            }
    }
    
    
    
    
    
    func removeChatMessage(chatMessageId: String) async {
        guard let hosueholdChatMessageCollectionRef = chatMessageCollectionRef else {
            return
        }
        
        let chatMessageDocRef = chatMessageCollectionRef?.document(chatMessageId)
        
        do {
            try await chatMessageDocRef?.delete()
        }
        catch {
            LogUtil.log("Error deleting chatMessage from Firestore: \(error)")
            self._error.send(error)
        }
    }
    
    func reset() {
        LogUtil.log("ChatMessageRepository -- resetting")
        chatMessageCollectionListener?.remove()
        chatMessageCollectionListener = nil
        _chatMessages.send(nil)
        _error.send(nil)
    }
    
    deinit {
        chatMessageCollectionListener?.remove()
    }
}
