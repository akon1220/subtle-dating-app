//
//  ChatLogView.swift
//  subtle
//
//  Created by Shufan Wen on 3/12/22.
//

import SwiftUI

struct ChatLogView: View {
    
    @ObservedObject var chatLogVM : ChatLogVM
    
    var body: some View {
                VStack{
                    ScrollView (.vertical, showsIndicators: false, content : {
                        ScrollViewReader { scrollViewProxy in
                            VStack {
                                ForEach(chatLogVM.chatMessages) { message in
                                    MessageView(message: message)
                                }
                                HStack{Spacer()}.id("empty")
                            }.onReceive(chatLogVM.$messageCount) { _ in
                                withAnimation(.easeOut(duration: 0.5)) {
                                    scrollViewProxy.scrollTo("empty", anchor: .bottom)
                                }
                            }
                        }
                        .background(Color(.init(white: 0.95, alpha: 1)))
                    })
                    
                    HStack(spacing: 15) {
                        
                        HStack(spacing: 15) {
                            
                            TextField("Message", text: $chatLogVM.chatText)
                                .foregroundColor(Color(.gray))
                                .font(.system(size: 17))
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.black.opacity(0.06))
                                .clipShape(Capsule())
                            
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Capsule())
                        
                        //send button
                        if (chatLogVM.chatText != "") {
                            
                            Button {
                                chatLogVM.handleSend()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 22))
                                    .rotationEffect(.init(degrees: 45))
                                    .padding(.all)
                                    .background(Color.black.opacity(0.07))
                                    .clipShape(Circle())
                                
                                    
                            }
                            
                        }
                        
   
                    }
                    .padding(.horizontal)
                    .animation(.easeOut)

                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.init(white: 0.95, alpha: 1)))
        }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        let chatLogVM = ChatLogVM(receiverId: nil)
        ChatLogView(chatLogVM: chatLogVM)
    }
}
