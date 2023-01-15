//
//  TabContainer.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

enum Tab {
    case feed
    case chat
    case profile
}

struct TabContainer: View {
    
    @State var selectedTab: Tab = .feed
    @ObservedObject var authVM: AuthVM
    @StateObject var feedVM = FeedVM()
    @StateObject var chatListVM = ChatListVM()
    @StateObject var profileVM = ProfileVM()
    
    var body: some View {
        NavigationView {
            Group {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        FeedView(feedVM: feedVM)
                            .navigationBarTitle("Feed", displayMode: .inline)
                    }.tabItem {
                        Label("Feed", systemImage:"list.bullet")
                    }
                    
                    NavigationView {
                        ChatListView(chatListVM: chatListVM)
                            .navigationBarTitle("Chat", displayMode: .inline)
                    }.tabItem {
                        Label("Chat", systemImage:"message")
                    }
                    
                    NavigationView {
                        ProfileView(profileVM: profileVM)
                            .navigationBarTitle("Profile", displayMode: .inline)
                    }.tabItem {
                        Label("Profile", systemImage:"person.crop.circle")
                    }
                }
            }.toolbar {
                ToolbarItem {
                    Button("Logout"){
                        authVM.logout()
                    }
                }
            }.navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct TabContainer_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthVM()
        let feedVM = FeedVM()
        TabContainer(authVM: authVM, feedVM: feedVM)
    }
}
