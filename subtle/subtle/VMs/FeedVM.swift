//
//  FeedVM.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import Combine
import SwiftUI
import Firebase

class FeedVM: ObservableObject {
    
    enum Sort {
        case name
        case university
        case birthdate
        case creation
        case likes
    }
    
    enum Order {
        case ascending
        case descending
    }
    
    private var firestoreService = FirestoreService()
    private var storageService = StorageService()
    
    //General Feed View
    @Published var posts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var showModal = false
    @Published var showFilterModal = false
    @Published var searchText: String = ""
    @Published var sort: Sort = .name
    @Published var order: Order = .ascending
    @Published var loadAmount = 100
    //@Published var cursor: QueryDocumentSnapshot?
    
    var searchedPosts: [Post] {
      if searchText.isEmpty {
        return posts
      } else {
        return posts
          .filter { $0.searchableString.contains(searchText.lowercased()) }
      }
    }
    
    init() {
        loadPosts()
    }
    
    
    func addPostAndImages(post: Post, images: [UIImage]) {
        self.storageService.addImages(images: images) { urls in
            var newPost = post
            newPost.pictures = urls
            self.firestoreService.addPost(post: newPost) { post in
                self.posts.insert(post, at:0)
            }
        }
    }
    
    func loadPosts() {
        self.posts = []
        self.firestoreService.loadPosts(number: self.loadAmount) { posts in
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
    
    func loadFilteredPosts(uniQuery: String, minAgeQuery: Double, maxAgeQuery: Double) {
        self.posts = []
        self.firestoreService.loadFilteredPosts(number: self.loadAmount,
                                                uniQuery: uniQuery, minAgeQuery: minAgeQuery, maxAgeQuery: maxAgeQuery) { posts in
            self.posts.append(contentsOf: posts)
        }
    }
    
}
