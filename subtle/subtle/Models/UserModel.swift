//
//  UserModel.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var email: String
    var university: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case university
    }
}
