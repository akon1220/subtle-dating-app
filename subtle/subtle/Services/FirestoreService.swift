//
//  FirestoreService.swift
//  subtle
//
//  Created by Shufan Wen on 3/8/22.
//

import Foundation
import Firebase
import SwiftUI

struct FirestoreService {
    
    
    func addPost(post: Post,
                 completion: @escaping(_ post: Post)->Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        do {
            guard let id = post.id else {
                print("Error post has no id")
                return
            }
            try FirebaseManager.shared.firestore.collection("Posts").document(id).setData(from: post)
            completion(post)
        } catch let setDataError as NSError {
            print("Error creating post:", setDataError)
            return
        }
    }
    
    func deletePost(post: Post,
                    completion: @escaping(_ success: Bool)->Void) {
        guard let currentUser = FirebaseManager.shared.currentUser else {
            print("Error current user is nil")
            return
        }
        if currentUser.id != post.posterId {
            print("Error current user is not the creator of the post")
            return
        }
        guard let id = post.id else {
            print("Error post has no id")
            return
        }
        FirebaseManager.shared.firestore.collection("Posts").document(id).delete() { err in
            if let err = err {
                print("Error deleting post:", err)
                completion(false)
            }
            completion(true)
        }
    }
    
    func modifyPost(post: Post,
                    updateData: [AnyHashable: Any],
                    completion: @escaping(_ post: Post)->Void) {
        //Check permissions, cannot do this using firebase permissions because users need write access for likes
        guard let currentUser = FirebaseManager.shared.currentUser else {
            print("Error current user is nil")
            return
        }
        if currentUser.id != post.posterId {
            print("Error current user is not the creator of the post")
            return
        }
        guard let id = post.id else {
            print("Error post has no id")
            return
        }
        print(updateData)
        let ref = FirebaseManager.shared.firestore.collection("Posts").document(id)
        ref.updateData(updateData) { err in
            if let err = err {
                print("Error updating data", err)
                return
            }
            ref.getDocument() { querySnapshot, err in
                if let err = err {
                    print("Error retrieving updated post:", err)
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    print("Error with nil query snapshot")
                    return
                }
                guard let updatedPost = try? querySnapshot.data(as: Post.self) else {
                    print("Error formatting query data as post")
                    return
                }
                completion(updatedPost)
            }
        }
    }
    
    func loadPosts(number: Int,
                   completion: @escaping(_ posts: [Post])->Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        let ref = FirebaseManager.shared.firestore.collection("Posts").limit(to: number).order(by: "creationDate" , descending: true)
        ref.getDocuments() { querySnapshot, err in
                if let err = err {
                    print("Error retrieving posts", err)
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    print("Error with nil query snapshot")
                    return
                }
                let posts = querySnapshot.documents.compactMap({ doc -> Post? in
                    return try? doc.data(as: Post.self)
                })
                completion(posts)
            }
    }
    
    static func loadPost(posterId: String, onSuccess: @escaping(_ post: Post) -> Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        
        FirebaseManager.shared.firestore.collection("Posts").document(posterId).getDocument {
            (snapshot, err) in
            
            guard let snap = snapshot else {
                print("Error")
                return
            }
            
            let dict = snap.data()
            
            guard let decoded = try? Post.init(fromDictionary: dict!) else {
                return
            }
            
            onSuccess(decoded)
            
        }
    }
    
    func getNameFromId(id: String,
                       completion: @escaping(_ name: String) -> Void) {
        FirebaseManager.shared.firestore.collection("Users").document(id).getDocument() { querySnapshot, error in
            if let error = error {
                print("Error retrieving user document:", error)
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Error with nil query snapshot")
                return
            }
            guard let user = try? querySnapshot.data(as: User.self) else {
                print("Error decoding user")
                return
            }
            let name = "\(user.firstName) \(user.lastName)"
            completion(name)
        }
    }
    
    func createChatListListener(senderId: String,
                                completion: @escaping(_ querySnapshot: QuerySnapshot?, _ err: Error?)->Void) -> ListenerRegistration {
        return FirebaseManager.shared.firestore
            .collection("Recents")
            .document(senderId)
            .collection("Messages")
            .order(by: "time")
            .addSnapshotListener { querySnapshot, error in
                completion(querySnapshot, error)
            }
    }
    
    func createChatLogListener(senderId: String,
                               receiverId: String,
                               completion: @escaping(_ querySnapshot: QuerySnapshot?, _ err: Error?)->Void ) -> ListenerRegistration {
        return FirebaseManager.shared.firestore
                .collection("Messages")
                .document(senderId)
                .collection(receiverId)
                .order(by: "time")
                .addSnapshotListener { querySnapshot, error in
                    completion(querySnapshot, error)
                }
    }
    
    func getChatListDocument(senderId: String,
                             receiverId: String) -> DocumentReference {
        return FirebaseManager.shared.firestore
                .collection("Recents")
                .document(senderId)
                .collection("Messages")
                .document(receiverId)
    }
    
    
    func getChatLogDocument(senderId: String,
                            receiverId: String) -> DocumentReference {
        return FirebaseManager.shared.firestore
                .collection("Messages")
                .document(senderId)
                .collection(receiverId)
                .document()
    }
    
    func likePost(post: Post, likerId: String, completion: @escaping(_ post: Post)->Void) {
        if !post.likes.contains(likerId) {
            guard let id = post.id else {
                print("Error post has no id")
                return
            }
            let ref = FirebaseManager.shared.firestore.collection("Posts").document(id)
            ref.updateData([
                "likes": FieldValue.arrayUnion([likerId])
            ]) { err in
                if let err = err {
                    print("Error liking post", err)
                    return
                }
                ref.getDocument() { querySnapshot, err in
                    if let err = err {
                        print("Error retrieving liked post:", err)
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        print("Error with nil query snapshot")
                        return
                    }
                    guard let updatedPost = try? querySnapshot.data(as: Post.self) else {
                        print("Error formatting query data as post")
                        return
                    }
                    completion(updatedPost)
                }
            }
        }
    }
    
    func unlikePost(post: Post, unlikerId: String, completion: @escaping(_ post: Post)->Void) {
        if post.likes.contains(unlikerId) {
            guard let id = post.id else {
                print("Error post has no id")
                return
            }
            let ref = FirebaseManager.shared.firestore.collection("Posts").document(id)
            ref.updateData([
                "likes": FieldValue.arrayRemove([unlikerId])
            ]) { err in
                if let err = err {
                    print("Error unliking post", err)
                    return
                }
                ref.getDocument() { querySnapshot, err in
                    if let err = err {
                        print("Error retrieving unliked post:", err)
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        print("Error with nil query snapshot")
                        return
                    }
                    guard let updatedPost = try? querySnapshot.data(as: Post.self) else {
                        print("Error formatting query data as post")
                        return
                    }
                    completion(updatedPost)
                }
            }
        }
    }
    
    func loadMyPosts(
                     completion: @escaping(_ posts: [Post])->Void) {
        guard let id = FirebaseManager.shared.currentUser?.id else {
            print("Error current user has no id")
            return
        }
        let ref = FirebaseManager.shared.firestore.collection("Posts").whereField("posterId", isEqualTo: id)
    
        ref.getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error retrieving posts", err)
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Error with nil query snapshot")
                return
            }
            guard let lastSnapshot = querySnapshot.documents.last else {
                print("Error with nil last document")
                return
            }
            let posts = querySnapshot.documents.compactMap({ doc -> Post? in
                return try? doc.data(as: Post.self)
            })
            completion(posts)
        }
    }
    
    
    func loadFilteredPosts(number: Int, uniQuery: String, minAgeQuery: Double, maxAgeQuery: Double,
                   completion: @escaping(_ posts: [Post])->Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        

        let minAgeBirthday = Calendar.current.date(byAdding: .year, value: -1*Int(minAgeQuery), to: Date())!
        let maxAgeBirthday = Calendar.current.date(byAdding: .year, value: -1*Int(maxAgeQuery), to: Date())!
        
        var calendarDateMin = Calendar.current.dateComponents([.day, .year, .month], from: minAgeBirthday)
        calendarDateMin.month = 1
        calendarDateMin.day = 1
        
        let userCalendarMin = Calendar(identifier: .gregorian)
        let minDateTime = userCalendarMin.date(from: calendarDateMin)
        
        var calendarDateMax = Calendar.current.dateComponents([.day, .year, .month], from: maxAgeBirthday)
        calendarDateMax.month = 12
        calendarDateMax.day = 31
        
        let userCalendarMax = Calendar(identifier: .gregorian)
        let maxDateTime = userCalendarMax.date(from: calendarDateMax)
       
        var ref = FirebaseManager.shared.firestore.collection("Posts").limit(to: number).order(by: "creationDate" , descending: true)
        
        if (uniQuery != "") {
            if (minAgeQuery == maxAgeQuery) {
                ref = FirebaseManager.shared.firestore.collection("Posts").whereField("birthday", isLessThan: maxDateTime as Any).whereField("birthday", isGreaterThan: minDateTime as Any).whereField("university", isEqualTo: uniQuery)
                }
            else {
            ref = FirebaseManager.shared.firestore.collection("Posts").whereField("birthday", isLessThan: minAgeBirthday).whereField("birthday", isGreaterThan:maxAgeBirthday).whereField("university", isEqualTo: uniQuery)
            }
        }
        else {
            if (minAgeQuery == maxAgeQuery) {
                ref = FirebaseManager.shared.firestore.collection("Posts").whereField("birthday", isLessThan: maxDateTime as Any).whereField("birthday", isGreaterThan: minDateTime as Any)
            }
            else {
            
        ref = FirebaseManager.shared.firestore.collection("Posts").whereField("birthday", isLessThanOrEqualTo: minAgeBirthday).whereField("birthday", isGreaterThanOrEqualTo:maxAgeBirthday)
        }
        }
        ref.getDocuments() { querySnapshot, err in
                if let err = err {
                    print("Error retrieving posts", err)
                    return
                }
                guard let querySnapshot = querySnapshot else {
                    print("Error with nil query snapshot")
                    return
                }
            
                let posts = querySnapshot.documents.compactMap({ doc -> Post? in
                    return try? doc.data(as: Post.self)
                })
                completion(posts)
            }
    }
    
}
