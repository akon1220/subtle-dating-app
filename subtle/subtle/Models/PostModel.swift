//
//  PostModel.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var posterId: String
    var name: String
    var university: String
    var location: String
    var birthday: Date // only display the age on a post
    var text: String
    var likes: [String] = []
    var tags: [String] = []
    var taggedUserIds: [String] = []
    var pictures: [URL] = []
    var childCommentIds: [String] = []
    var creationDate = Date()
    
    var searchableString: String {
      "\(name) \(text) \(university) \(location)".lowercased()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case posterId
        case name
        case university
        case location
        case birthday
        case text
        case likes
        case tags
        case taggedUserIds
        case pictures
        case childCommentIds
        case creationDate
    }
}

extension Post {
    static let dummyPost = Post(posterId: "dummy",
                                name: "dummy",
                                university: "dummy",
                                location: "dummy",
                                birthday: Date(),
                                text: "dummy")
}

