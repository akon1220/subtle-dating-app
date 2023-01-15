//
//  ProfileVM.swift
//  subtle
//
//  Created by KX on 3/24/22.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class ProfileVM: ObservableObject {
    
    @Published var user: String
    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var university: String
    @Published var myPosts: [Post] = []
    
    private var authService = AuthService()
    private var storageService = StorageService()
    private var firestoreService = FirestoreService()
    
    @Published var posts: [Post] = []
    @Published var cursor: QueryDocumentSnapshot?
    
    init() {
        self.firstName = authService.getUser()?.firstName ?? " "
        self.lastName = authService.getUser()?.lastName ?? " "
        self.email = authService.getUser()?.email ?? " "
        self.user = authService.getUser()?.id ?? " "
        self.university = authService.getUser()?.university ?? " "
        loadMyPosts()
        
    }
    
    func loadMyPosts() {
        self.posts = []
        self.firestoreService.loadMyPosts() { posts in
                self.posts.append(contentsOf: posts)
            }
    }
    
    func deletePost(post: Post) {
        if let index = self.posts.firstIndex(where: {$0.id == post.id}) {
            self.firestoreService.deletePost(post: post) { success in
                if success {
                    self.posts.remove(at: index)
                }
            }
        }
    }
    
    
}


