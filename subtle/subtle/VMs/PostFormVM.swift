//
//  PostFormVM.swift
//  subtle
//
//  Created by Jenny Li on 3/20/22.
//

import Foundation
import Combine
import SwiftUI

class PostFormVM: ObservableObject {
    //List of colleges in the US
    @Published var universityList: [String] = ["loading universities"]
    
    @Published var name = ""
    @Published var date = Date()
    @Published var university = ""
    @Published var location = ""
    @Published var text = ""
    @Published var tags: [String] = []
    @Published var tagText: String = ""
    @Published var showAlert : Bool = false
    @Published var images: [UIImage] = []
    @Published var firstSubmitAttempted = false
    
    var nameError: Bool {
        return firstSubmitAttempted && name == ""
    }
    var birthdateError: Bool {
        return firstSubmitAttempted && !(18 < PostVM.calcAge(birthday: date) && PostVM.calcAge(birthday: date) < 30)
    }
    var universityError: Bool {
        return firstSubmitAttempted && university == ""
    }
    var locationError: Bool {
        return firstSubmitAttempted && location == ""
    }
    var textError: Bool {
        return firstSubmitAttempted && text == ""
    }
    var imagesError: Bool {
        return firstSubmitAttempted && images == []
    }
    
    func postFormIsValid() -> Bool {
        return !(nameError || birthdateError || universityError || locationError || textError || imagesError)
    }
    
    func submitForm() {
        firstSubmitAttempted = true
    }
    
    func getUniversities() async {
        do {
            let response = try await CollegeAPIService.fetch()
            self.universityList = response
        } catch {
            self.universityList = ["\(error)"]
        }
        
    }
    
    
    
    
    
    
    
}
