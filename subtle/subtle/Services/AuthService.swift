//
//  AuthService.swift
//  subtle
//
//  Created by Shufan Wen on 3/8/22.
//

import Foundation
import Firebase

struct AuthService {
    
    func login(email: String,
               password: String,
               completion: @escaping(_ loginStatus:Bool)->Void) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Error login user:", err)
                return
            }
            guard let uid = result?.user.uid else {
                print("Error retriving user id")
                return
            }
            FirebaseManager.shared.firestore.collection("Users").document(uid).getDocument() { document, err in
                if let err = err {
                    print("Error retrieving user:", err)
                    return
                }
                guard let doc = document else {
                    print("Error unpacking document")
                    return
                }
                do {
                    FirebaseManager.shared.currentUser = try doc.data(as: User.self)
                    completion(true)
                } catch let error as NSError {
                    print("Error decoding last user:", error)
                }
            }
        }
    }
    
    func register(email: String,
                  password: String,
                  firstName: String,
                  lastName: String,
                  university: String,
                  completion: @escaping(_ loginStatus:Bool)->Void) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Error creating user:", err)
                return
            }
            guard let uid = result?.user.uid else {
                print("Error extracting user uid:")
                return
            }
            let newUser = User(id: uid,
                               firstName: firstName,
                               lastName: lastName,
                               email: email,
                               university: university)
            do {
                try FirebaseManager.shared.firestore.collection("Users").document(uid).setData(from: newUser)
                print("Successfully created user: \(result?.user.uid ?? "")")
                FirebaseManager.shared.currentUser = newUser
                completion(true)
            } catch let setDataError as NSError {
                print("Error setting user:", setDataError)
                return
            }
        }
    }
    
    func logout(completion: @escaping(_ loginStatus:Bool)->Void) {
        do {
            try FirebaseManager.shared.auth.signOut()
            FirebaseManager.shared.currentUser = nil
            completion(false)
        } catch let signOutError as NSError {
          print("Error signing out:", signOutError)
        }
    }
    
    func getUser() -> User? {
        return FirebaseManager.shared.currentUser
    }
    
}
