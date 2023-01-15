//
//  LoginView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
    @ObservedObject var authVM: AuthVM

    
    var body: some View {
        VStack {
            Text("Welcome Back").font(.title)
            Image("subtlefish-transparent").resizable().frame(width: 100, height: 100)
            Form {
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                Section(header: Text("Password")) {
                    SecureField("Password", text: $password)
                }
                Button("Login") {
                    authVM.login(email: email, password: password)
                }.disabled(email.isEmpty || password.isEmpty)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthVM()
        LoginView(authVM: authVM)
    }
}
