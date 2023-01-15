//
//  MessageView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct MessageView: View {
    
    let message: Message
    
    var body: some View {
        if message.senderId == FirebaseManager.shared.currentUser?.id {
            HStack (spacing: 10) {
                Spacer(minLength: 25)
                HStack {
                    Text(message.text).foregroundColor(.white)
                }
                .padding(.all)
                .background(Color.blue)
                .cornerRadius(15)
            }
        } else {
            HStack {
                HStack {
                    Text(message.text).foregroundColor(.black)
                }
                .padding(.all)
                .background(Color.black.opacity(0.06))
                .cornerRadius(15)
                Spacer(minLength: 25)
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: Message.dummyMessage)
    }
}
