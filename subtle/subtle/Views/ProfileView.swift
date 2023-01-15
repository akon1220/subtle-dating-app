//
//  ProfileView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profileVM: ProfileVM
    
    var body: some View {
            VStack (spacing: 0) {
            HStack{
                Text("First Name: ").font(.headline)
                Text(profileVM.firstName).font(.body)
                Spacer()
            }.padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))
            Divider()
            HStack {
                Text("Last Name: ").font(.headline)
                Text(profileVM.lastName).font(.body)
                Spacer()
            }.padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))
            Divider()
            HStack {
                    Text("University: ").font(.headline)
                    Text(profileVM.university).font(.body)
                    Spacer()
                }.padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))
            Divider()
            HStack {
                Text( "Email: ").font(.headline)
                Text(profileVM.email).font(.body)
                Spacer()
            }.padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))
            Divider()
            HStack {
                NavigationLink(destination: myPosts.onAppear() {
                    profileVM.loadMyPosts()
                }) {
                    Text("Posts You've Made").font(.headline)
                    Image(systemName: "chevron.right")
                }
                }.padding(EdgeInsets(top: 17, leading: 21, bottom: 17, trailing: 21))

            }.padding(.top, -300)
    }
    
    var myPosts: some View {
    List {
      ForEach(profileVM.posts) { post in
          PostView(postVM: PostVM(post: post))
              .padding()
              .border(Color.black, width: 2)
              .listRowSeparator(.hidden)
              .deleteDisabled(post.posterId != FirebaseManager.shared.currentUser?.id)
      }.onDelete(perform: delete)
  }
    }
    
    func delete(at offsets: IndexSet) {
        let offsetList = Array(offsets)
        let deletePosts = offsetList.map({ idx in
            return profileVM.posts[idx]
        })
        deletePosts.forEach({ post in
            profileVM.deletePost(post: post)
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileVM = ProfileVM()
        ProfileView(profileVM: profileVM)
    }
}
