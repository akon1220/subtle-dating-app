//
//  ChatView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct ChatListView: View {
    
    @ObservedObject var chatListVM : ChatListVM
    
    var body: some View {
        List(chatListVM.recentMessages) { message in
            let id = (message.senderId != chatListVM.sender?.id ?  message.senderId : message.receiverId)
            let chatLogVM = ChatLogVM(receiverId: id)
            NavigationLink (destination: ChatLogView(chatLogVM: chatLogVM)) {
                HStack {
                    Image(systemName: "person.crop.circle").font(.system(size: 32)).padding()
                    VStack (alignment: .leading) {
                        Text(chatListVM.idToUserNames[id] ?? "").font(.headline)
                        if (message.text.count < 24) {
                            Text(message.text)
                        } else {
                            Text(message.text.prefix(24) + "...")
                        }
                    }
                }
            }
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        let chatListVM = ChatListVM()
        ChatListView(chatListVM: chatListVM)
    }
}
