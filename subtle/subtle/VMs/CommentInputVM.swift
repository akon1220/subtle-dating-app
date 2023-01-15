//
//  CommentInputVM.swift
//  subtle
//
//  Created by Jimin Cheon on 4/11/22.
//

import SwiftUI

class CommentInputVM: ObservableObject {
    
    @ObservedObject var commentService = CommentService()
    
    init(post: Post?) {
        if post != nil {
           commentService.post = post
        } else {
            guard let postId = post?.id else {
                print("PostId is null")
                return
            }
            handleInput(postId: postId)
        }
    }
    
    func handleInput(postId: String) {
        FirestoreService.loadPost(posterId: postId) {
            (post) in
            print("Loading")
            self.commentService.post = post
        }
    }
    
    func sendComment(input: String) {
        if input != "" {
            commentService.addComment(comment: input) {
                print("it sent")
            }
        }
        print(input + "<- message")
    }
}
