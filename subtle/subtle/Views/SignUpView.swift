//
//  SignUpView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct SignUpView: View {
    
    @ObservedObject var authVM: AuthVM
    
    var body: some View {
        VStack {
            Text("Welcome to Subtle").font(.title)
            Image("subtlefish-transparent").resizable().frame(width: 100, height: 100)
            Form {
                Section(header: Text("First Name")) {
                    TextField("First Name", text: $authVM.firstName)
                        .autocapitalization(.words)
                        .listRowSeparator(.hidden)
                    if authVM.firstNameError {
                        Text("Please enter a first name!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("Last Name")) {
                    TextField("Last Name", text: $authVM.lastName)
                        .autocapitalization(.words)
                        .listRowSeparator(.hidden)
                    if authVM.lastNameError {
                        Text("Please enter a last name!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("University")) {
                    Picker("University", selection: $authVM.university) {
                        ForEach(authVM.universityList) {
                            Text($0.name).tag($0)
                        }
                    }
                    if authVM.universityError {
                        Text("Please select your university!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                .task { await authVM.getUniversities() }
                Section(header: Text("Email")) {
                    TextField("Valid .edu Email", text: $authVM.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    if !authVM.emailEmptyError && authVM.emailInvalidError {
                        Text("Email does not match university selected.")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                    if authVM.emailEmptyError {
                        Text("Please enter a valid .edu email!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("Password")) {
                    SecureField("Password", text: $authVM.password)
                    if authVM.passwordError {
                        Text("Please choose a password that is 6 or more characters.")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Button("Sign Up") {
                    authVM.register()
        
                }
            }
        }
    }
    
}
    
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthVM()
        SignUpView(authVM: authVM)
    }
}
