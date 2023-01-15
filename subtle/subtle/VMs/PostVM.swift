//
//  PostVM.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import Combine
import SwiftUI

class PostVM: ObservableObject {
    
    private var firestoreService = FirestoreService()
    private var storageService = StorageService()
    private var authService = AuthService()
    
    private var imagesToDelete : [URL] = []
    
    @Published var post: Post
    //For edit modal if need be
    @Published var showModal = false
    @Published var editName: String
    @Published var editDate: Date
    @Published var editUniversity: String
    @Published var editLocation: String
    @Published var editText: String
    @Published var editTag: [String]
    @Published var editImages: [URL]
    @Published var additionalImages: [UIImage] = []
    //Images to delete
    @Published var selected: Set<URL> = []
    //List of colleges in the US
    @Published var universityList: [String] = ["loading universities"]
    //whether user has liked post or not
    var hasLikedPost: Bool {
        guard let id = authService.getUser()?.id else { return false}
        return self.post.likes.contains(id)
    }
    
    init(post: Post) {
        self.post = post
        self.editName = post.name
        self.editDate = post.birthday
        self.editUniversity = post.university
        self.editLocation = post.location
        self.editText = post.text
        self.editTag = post.tags
        self.editImages = post.pictures
    }
    
    func editPostAndImages() {
        var editParams : [String: Any] = [:]
        if post.name != editName {
            editParams["name"] = editName
        }
        if post.birthday != editDate {
            editParams["birthday"] = editDate
        }
        if post.university != editUniversity {
            editParams["university"] = editUniversity
        }
        if post.location != editLocation {
            editParams["location"] = editLocation
        }
        if post.text != editText {
            editParams["text"] = editText
        }
        if post.tags != editTag {
            editParams["tags"] = editTag
        }
        
        var newImages = editImages
        if !self.additionalImages.isEmpty {
            self.storageService.addImages(images: self.additionalImages) { urls in
                newImages.append(contentsOf: urls)
                let newImageStrings = newImages.map {$0.absoluteString}
                editParams["pictures"] = newImageStrings
                self.firestoreService.modifyPost(post: self.post, updateData: editParams) { post in
                    self.post = post
                }
            }
            return
        }
        let newImageStrings = newImages.map {$0.absoluteString}
        editParams["pictures"] = newImageStrings
        
        print(editParams)
        self.firestoreService.modifyPost(post: self.post, updateData: editParams) { post in
            self.post = post
        }
        
        self.storageService.deleteImages(urls: imagesToDelete) { successes in
            print(successes)
        }
    }
    
    
    func getUniversities() async {
        do {
            let response = try await CollegeAPIService.fetch()
            self.universityList = response
        } catch {
            self.universityList = ["API error"]
        }
        
    }
    
    func likePost() {
        guard let likerId = authService.getUser()?.id else { return }
        self.firestoreService.likePost(post: self.post, likerId: likerId) { post in
            self.post = post
        }
    }
    
    func unlikePost() {
        guard let likerId = authService.getUser()?.id else { return }
        self.firestoreService.unlikePost(post: self.post, unlikerId: likerId) { post in
            self.post = post
        }
    }
    
    func deleteImages() {
        let imagesToRetain = Array(Set(self.editImages).subtracting(self.selected))
        self.imagesToDelete.append(contentsOf: self.selected)
        print(self.imagesToDelete)
        self.selected = []
        self.editImages = imagesToRetain
    }

static func calcAge (birthday: Date) -> Int {
    let now = Date()
    let birthday: Date = birthday
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
    let age = ageComponents.year!
    return age
}
}
