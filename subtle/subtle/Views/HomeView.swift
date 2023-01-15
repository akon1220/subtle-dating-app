//
//  HomeView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("onboarding") var isOnboardingActive: Bool = false
    @ObservedObject var authVM: AuthVM
    
    var body: some View {
                
                NavigationView {
                    
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color(uiColor: UIColor.magenta).opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        
                            ZStack {
                                
                                Circle()
                                    .frame(width: 400, height: 400)
                                    .offset(x: 150, y: -200)
                                    .foregroundColor(Color.purple.opacity(0.4))
                                    .blur(radius: 8)
                                
                                Circle()
                                    .frame(width: 300, height: 300)
                                    .offset(x: -50, y: -125)
                                    .foregroundColor(Color.blue.opacity(0.2))
                                    .blur(radius: 8)
                                
                                
                                Color.white.opacity(0.4)
                                    .frame(width: 300, height: 400)
                                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
//                                    .blur(radius: 2)
                                    
                        
                                VStack {
                                    Text("Subtle Dating App").font(.title)
                                    Spacer().frame(height: 50)
                                    NavigationLink(destination: SignUpView(authVM: authVM)){
                                            Text("Sign Up")
                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                .frame(width: 150, height: 40)
                                                .background(Color.white)
                                                .cornerRadius(20)
                                    }
                                    Spacer().frame(height: 10)
                                    NavigationLink(destination: LoginView(authVM: authVM)){
                                        Text("Log In")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .frame(width: 150, height: 40)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                    }
                                    
                                    
                                    Spacer().frame(height: 50)
                                    
                                    Button(action: {
                                        withAnimation {
                                            isOnboardingActive = true
                                        }
                                    }) {
                                        
                                        Image(systemName: "chevron.backward.2")
                                            .imageScale(.large)
                                        
                                        Text("Go Back")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))

                                    }
                                    .frame(width: 150, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                }
                                .padding()
                                .frame(width: 300, height: 400)
                                .foregroundColor(Color.black.opacity(0.8))
                                
                        }
            }.edgesIgnoringSafeArea(.all)
            
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthVM()
        HomeView(authVM: authVM)
    }
}
