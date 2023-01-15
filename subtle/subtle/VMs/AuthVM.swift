//
//  AuthVM.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import Foundation
import Combine

@MainActor class AuthVM: ObservableObject {
    private var authService = AuthService()
    @Published var email = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var university = College.dummyCollege
    @Published var password = ""
    @Published var loggedIn = false
    @Published var universityList: [College] = [College.dummyCollege]
    @Published var firstSubmitAttempted = false
    var firstNameError: Bool {
        return firstSubmitAttempted && firstName == ""
    }
    var lastNameError: Bool {
        return firstSubmitAttempted && lastName == ""
    }
    var emailEmptyError: Bool {
        return firstSubmitAttempted && email == ""
    }
    var emailInvalidError: Bool {
        return firstSubmitAttempted && !emailIsValid()
    }
    var universityError: Bool {
        return firstSubmitAttempted && university == College.dummyCollege
    }
    var passwordError: Bool {
        return firstSubmitAttempted && password.count < 6
    }
    
    func login(email: String, password: String) {
        
        authService.login(email: email, password: password) { loginStatus in
            self.loggedIn = loginStatus
        }
        
    }
    
    func formIsValid() -> Bool {
        return !(firstNameError || lastNameError || emailEmptyError || emailInvalidError || universityError || passwordError)
    }
    
    func emailIsValid() -> Bool
    {
        let emailComponents = email.components(separatedBy: "@")
        if email.contains("@") && emailComponents[1] == university.domain {
            return true
        }
        return false
    }
    
    func register() {
            firstSubmitAttempted = true
            if formIsValid() {
                authService.register(email: email,
                                     password: password,
                                     firstName: firstName,
                                     lastName: lastName,
                                     university: university.name) { loginStatus in
                    self.loggedIn = loginStatus
                }
            }
    }
    
    func logout() {
        authService.logout() { loginStatus in
            self.loggedIn = loginStatus
        }
    }
    
    func getUniversities() async {
        do {
            let response = try await CollegeAPIService.fetchColleges()
            self.universityList = response
        } catch {
            self.universityList = [College(name: error.localizedDescription, domain: "error.edu")]
        }
        
    }
}

