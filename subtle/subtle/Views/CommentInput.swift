//
//  CommentInput.swift
//  subtle
//
//  Created by Jimin Cheon on 3/22/22.
//

import SwiftUI

struct CommentInput: View {
    @ObservedObject var commentInputVM : CommentInputVM
    @State var input = ""
    
    var body: some View {
        HStack() {
            HStack {
                TextField("Add a comment", text: self.$input)
                    .padding(.leading, 20)
                Button(action: {commentInputVM.sendComment(input: input); input = ""},
                       label: {
                    Image(systemName: "paperplane")
                        .imageScale(.large)
                    .padding(.trailing) } )
                
            }
            .padding(.bottom, 10)
        }
    }
}

