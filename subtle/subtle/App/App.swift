//
//  App.swift
//  subtle
//
//  Created by Shufan Wen on 3/3/22.
//

import SwiftUI

@main
struct subtleApp: App {
    @StateObject var authVM = AuthVM()
    @AppStorage("onboarding") var isOnboardingActive: Bool = true
    
    var body: some Scene {
        WindowGroup {
            if authVM.loggedIn {
                TabContainer(authVM: authVM)
            } else {
                ZStack {
                    if isOnboardingActive {
                        Onboarding()
                    } else {
                        HomeView(authVM: authVM)
                    }
                }
            }
            
            

        }
    }
}
