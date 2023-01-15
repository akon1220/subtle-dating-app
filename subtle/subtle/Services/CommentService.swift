//
//  CommentService.swift
//  subtle
//
//  Created by Jimin Cheon on 3/22/22.
//

import Foundation
import Firebase

class CommentService: ObservableObject {
    
    @Published var isLoading = false
    @Published var comments: [CommentModel] = []
    var postId: String = ""
    var listener: ListenerRegistration?
    var post: Post?
    
    private var firestoreService = FirestoreService()
    
    static var commentsRef = FirebaseManager.shared.firestore.collection("comments")
    
    static func commentsId(postId: String) -> DocumentReference {
        return commentsRef.document(postId)
    }
    
    func postComment(comment: String, username: String, ownerId: String, postId: String, onSuccess: @escaping()-> Void, onError: @escaping(_ error: String) -> Void) {
    
        let comment = CommentModel(postId: postId, comment: comment, username: username, date: Date().timeIntervalSince1970, ownerId: ownerId)
        print(comment)
        guard let dict = try? comment.asDictionary() else {
            print("Dict fail")
            return
        }
        
        CommentService.commentsId(postId: postId).collection("comments").addDocument(data: dict) {
            (err) in
            if let err = err {
                onError(err.localizedDescription)
                return
            }
            
            onSuccess()
        }
    }
    
    func getComments(postId: String, onSuccess: @escaping ([CommentModel]) -> Void, onError: @escaping(_ error: String) -> Void,
                     newComment: @escaping(CommentModel) -> Void, listener: @escaping(_ listenerHandle: ListenerRegistration) -> Void) {
        
        let listenerPosts = CommentService.commentsId(postId: postId).collection("comments").order(by: "date", descending: false).addSnapshotListener {
            
            (snapShot, error) in
            guard let snapShot = snapShot else { return }
            
            var comments = [CommentModel]()
            
            snapShot.documentChanges.forEach{
                (diff) in
                if ( diff.type == .added  ) {
                    let dict = diff.document.data()
                    guard let decoded = try? CommentModel.init(fromDictionary: dict) else {
                        return
                    }
                
                newComment(decoded)
                comments.append(decoded)
                }
                
                if ( diff.type == .modified ) {
                    print("Mod")
                }
                
                if ( diff.type == .removed ) {
                    print("Removed")
                }
            }
            onSuccess(comments)
        }
        listener(listenerPosts)
    }
    
    func loadComment() {
        self.comments = []
        self.isLoading = true
        
        self.getComments(postId: postId, onSuccess: {
            
            (comments) in
            if self.comments.isEmpty {
                self.comments = comments
            }
        }, onError: {
            (err) in
        }, newComment: {
            (comment) in
            
            if !self.comments.isEmpty {
                self.comments.append(comment)
            }
        }) {
            (listener) in
            self.listener = listener
        }
    }
    
    func addComment(comment: String, onSuccess: @escaping() -> Void) {
        print("It got here1")
        guard let currUserId = Auth.auth().currentUser?.uid else {
            return
        }
        print(currUserId)
        print("It got here2")
        firestoreService.getNameFromId(id: currUserId) {
            fullName in
            
            guard let postId = self.post?.id else {
                print("PostId failed CommentService")
                return
            }
            
            self.postComment(comment: comment, username: fullName, ownerId: currUserId, postId: postId, onSuccess: {
                onSuccess()
            }) {
                (err) in
                print("No work")
            }
        }
        print("It got here3")

        
    }
    
}
