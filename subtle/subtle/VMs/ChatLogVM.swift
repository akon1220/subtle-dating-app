//
//  ChatLogVM.swift
//  subtle
//
//  Created by Shufan Wen on 3/12/22.
//

import Foundation
import Firebase

class ChatLogVM: ObservableObject {
    
    @Published var chatText = ""
    @Published var chatMessages : [Message] = []
    @Published var messageCount = 0
    
    var listener: ListenerRegistration?
    
    private var senderId: String?
    private var recieverId: String?
    private var firestoreService = FirestoreService()
    private var authService = AuthService()
    
    init(receiverId: String?) {
        let sender = authService.getUser()
        self.senderId = sender?.id
        self.recieverId = receiverId
        self.fetchMessages()
    }
    
    func fetchMessages() {
        guard let senderId = self.senderId else { return }
        guard let receiverId = self.recieverId else { return }
        self.listener?.remove()
        self.chatMessages.removeAll()
        self.listener = firestoreService.createChatLogListener(senderId: senderId,
                                                               receiverId: receiverId) { querySnapshot, error in
            if let error = error {
                print("Error creating chat log listener:", error)
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    guard let message = try? change.document.data(as: Message.self) else {
                        print("Error decoding message")
                        return
                    }
                    self.chatMessages.append(message)
                }
            })
            DispatchQueue.main.async {
                self.messageCount += 1
            }
        }
    }
    
    //Saves for chat log history with a specific user
    func handleSend() {
        guard let senderId = self.senderId else { return }
        guard let receiverId = self.recieverId else { return }
        let message = Message(senderId: senderId,
                              receiverId: receiverId,
                              text: chatText)
        let senderDocument = self.firestoreService.getChatLogDocument(senderId: senderId, receiverId: receiverId)
        try? senderDocument.setData(from: message) { error in
            if let error = error {
                print("Error saving sender chat history:", error)
                return
            }
            self.persistRecentMessage(message: message)
            self.chatText = ""
            self.messageCount += 1
        }
        let receiverDocument = self.firestoreService.getChatLogDocument(senderId: receiverId, receiverId: senderId)
        try? receiverDocument.setData(from: message) { error in
            if let error = error  {
                print("Error saving reciever chat history:", error)
                return
            }
        }
    }
    
    //Saves for chat list when displaying the most recent message
    func persistRecentMessage(message: Message) {
        guard let senderId = self.senderId else { return }
        guard let receiverId = self.recieverId else { return }
        let senderDocument = self.firestoreService.getChatListDocument(senderId: senderId, receiverId: receiverId)
        try? senderDocument.setData(from: message) { error in
            if let error = error {
                print("Error saving sender recent message:", error)
                return
            }
        }
        let receiverDocument = self.firestoreService.getChatListDocument(senderId: receiverId, receiverId: senderId)
        try? receiverDocument.setData(from: message) { error in
            if let error = error {
                print("Error saving receiver recent message:", error)
                return
            }
        }
    }
}
