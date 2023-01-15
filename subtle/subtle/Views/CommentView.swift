//
//  CommentView.swift
//  subtle
//
//  Created by Jimin Cheon on 3/22/22.
//

import SwiftUI

struct CommentView: View {
    @StateObject var commentService = CommentService()
    
    var post: Post
    
    var body: some View {
        VStack {
            ScrollView {
                if !commentService.comments.isEmpty {
                    ForEach(commentService.comments) {
                        (comment) in
                        CommentCardView(comment: comment)
                    }
                }
            }
            CommentInput(commentInputVM: CommentInputVM(post: post))
        }
        .navigationTitle("Comments")
        
        .onAppear {
            
            guard let postId = self.post.id else {
                print("PostId failed CommentView")
                return
            }
            
            self.commentService.postId = postId
            
            self.commentService.loadComment()
        }
        .onDisappear {
            if self.commentService.listener != nil {
                self.commentService.listener?.remove()
            }
        }
    }
}
