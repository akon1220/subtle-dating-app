//
//  MessageModel.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var senderId: String
    var receiverId: String
    var text: String
    var time: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case receiverId
        case text
        case time
    }

}


extension Message {
    static let dummyMessage = Message(senderId: "dummy", receiverId: "dummy", text: "dummy")
    
}
