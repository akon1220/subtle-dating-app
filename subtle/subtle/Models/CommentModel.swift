//
//  CommentModel.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct CommentModel: Identifiable, Encodable, Decodable {
    var id = UUID()
    var postId: String
    var comment: String
    var username: String
    var date: Double
    var ownerId: String
}
