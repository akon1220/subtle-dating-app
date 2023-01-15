//
//  StorageService.swift
//  subtle
//
//  Created by Shufan Wen on 3/8/22.
//

import Foundation
import Firebase
import SwiftUI

//Define BatchUploader to handle uploading multiple images at once
//Due to the asychronous nature of the Firebase SDK recursion needs to replace iteration

struct StorageService {
    
    func addImages(images: [UIImage],
                   completion: @escaping(_ urls: [URL])->Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        var urls: [URL] = []
        let recursiveClosure = { (url: URL) -> Void in
            urls.append(url)
        }
        let finalClosure = { () -> Void in
            completion(urls)
        }
        self.addImageHelper(images: images,
                            index: 0,
                            completion: recursiveClosure,
                            finalCompletion: finalClosure)
    }
    
    func addImageHelper(images: [UIImage],
                        index: Int,
                        completion: @escaping(_ url: URL)->Void,
                        finalCompletion: @escaping()->Void) {
        if (index < images.count) {
            let image = images[index]
            BatchUploader.shared.upload(image: image) { url in
                completion(url)
                self.addImageHelper(images: images,
                                    index: index+1,
                                    completion: completion,
                                    finalCompletion: finalCompletion)
            }
        } else {
            finalCompletion()
        }
    }
    
    func deleteImages(urls: [URL],
                      completion: @escaping (_ successes: [Bool])->Void) {
        if FirebaseManager.shared.currentUser == nil {
            print("Error current user is nil")
            return
        }
        var successes: [Bool] = []
        let recursiveClosure = { (success: Bool) -> Void in
            successes.append(success)
        }
        let finalClosure = { ()-> Void in
            completion(successes)
        }
        self.deleteImageHelper(urls: urls,
                               index: 0,
                               completion: recursiveClosure,
                               finalCompletion: finalClosure)
    }
    
    func deleteImageHelper(urls: [URL],
                           index: Int,
                           completion: @escaping(_ success: Bool)->Void,
                           finalCompletion: @escaping()->Void) {
        if (index < urls.count) {
            let url = urls[index]
            BatchUploader.shared.delete(url: url) { success in
                completion(success)
                self.deleteImageHelper(urls: urls,
                                       index: index+1,
                                       completion: completion,
                                       finalCompletion: finalCompletion)
            }
        } else {
            finalCompletion()
        }
    }
}


struct BatchUploader {
    
    static let shared = BatchUploader()
    static let ref = FirebaseManager.shared.storage.reference()
    
    
    func upload(image: UIImage,
                completion: @escaping (_ url: URL) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Error extracting image data")
            return
        }
        let path = UUID().uuidString
        guard let posterId = FirebaseManager.shared.currentUser?.id else {
            print("Error with no poster id")
            return
        }
        let finalRef = BatchUploader.ref.child(posterId).child(path)
        finalRef.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Error uploading image data:", err)
                return
            }
            finalRef.downloadURL() { url, err in
                if let err = err {
                    print("Error downloading url:", err)
                    return
                }
                guard let url = url else {
                    print("Error ")
                    return
                }
                completion(url)
            }
        }
    }
    
    func delete(url: URL,
                completion: @escaping (_ success: Bool) -> Void) {
        let finalRef = FirebaseManager.shared.storage.reference(forURL: url.absoluteString)
        finalRef.delete() { err in
            if let err = err {
                print("Error deleting image data:", err)
                completion(false)
            }
            completion(true)
        }
    }
}
