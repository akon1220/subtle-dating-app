//
//  ChatVM.swift
//  subtle
//
//  Created by Shufan Wen on 3/12/22.
//

import Foundation
import Firebase

class ChatListVM: ObservableObject {
    
    @Published var recentMessages : [Message] = []
    @Published var idToUserNames : [String: String] = [:]
    @Published var sender: User?
    
    var listener: ListenerRegistration?
    private var firestoreService = FirestoreService()
    private var authService = AuthService()
    
    init() {
        self.sender = authService.getUser()
        self.fetchRecentMessages()
    }
    
    func fetchRecentMessages() {
        guard let id = sender?.id else { return }
        self.listener?.remove()
        self.recentMessages.removeAll()
        self.listener = firestoreService.createChatListListener(senderId: id) { querySnapshot, err in
            if let err = err {
                print("Error creating chat list listener:", err)
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Error nil query snapshot")
                return
            }
            querySnapshot.documentChanges.forEach({ change in
                let docId = change.document.documentID
                guard let message = try? change.document.data(as: Message.self) else {
                    print("Error decoding recent message")
                    return
                }
                if let index = self.recentMessages.firstIndex(where: {$0.id == docId}) {
                    self.recentMessages.remove(at: index)
                }
                self.recentMessages.insert(message, at: 0)
                let idForRetrieval = (message.senderId != id ?  message.senderId : message.receiverId)
                if self.idToUserNames[idForRetrieval] == nil {
                    self.firestoreService.getNameFromId(id: idForRetrieval) { fullName in
                        self.idToUserNames[idForRetrieval] = fullName
                    }
                }
            })
        }
    }
}
