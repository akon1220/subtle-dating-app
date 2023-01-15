//
//  PostView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostView: View {
    
    @ObservedObject var postVM: PostVM
    @State var isActive = false
    @State var isActiveComment = false
    
    var body: some View {
        VStack {
            if FirebaseManager.shared.currentUser?.id == postVM.post.posterId {
                HStack {
                    Spacer()
                    Button(action: { postVM.showModal = true },
                           label: { Text("Edit").font(.system(size: 12.5)) })
                        .buttonStyle(BorderlessButtonStyle())
                }
            }

            VStack {
                    Text("\(postVM.post.name), \(PostVM.calcAge(birthday: postVM.post.birthday))").font(.headline)
                Text(postVM.post.university).font(.subheadline)
            }
            Divider().background(Color.black)
            Text(postVM.post.text).font(.body).multilineTextAlignment(.leading)
            //Divider().background(Color.black)
            
            //Tags...
            ScrollView(.horizontal) {
                HStack() {
                    ForEach(postVM.post.tags, id: \.self) {
                        tag in
                        Text(tag)
                            .modifier(tagSectionHeader())
                    }
                }
            }
            if let urls = postVM.post.pictures {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(urls, id:\.self) {url in
                            WebImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                        }
                    }
                }
            }
            Text("Likes: \(String(postVM.post.likes.count))").font(.caption)
            Divider().background(Color.black)
            HStack {
                if postVM.hasLikedPost {
                    Button(action:{ postVM.unlikePost() }, label:{Image(systemName: "heart.fill")}).buttonStyle(BorderlessButtonStyle()).foregroundColor(.red).frame(maxWidth: .infinity)
                } else {
                    Button(action:{
                        postVM.likePost() }, label:{Image(systemName: "heart")}).buttonStyle(BorderlessButtonStyle()).foregroundColor(.gray).frame(maxWidth: .infinity)
                }

                Button(action: { self.isActiveComment = true },
                       label: {Text("Comments")})
                    .buttonStyle(BorderlessButtonStyle()).frame(maxWidth: .infinity)
                NavigationLink(destination: CommentView(post: postVM.post),
                               isActive: $isActiveComment){EmptyView()}
                               .buttonStyle(BorderlessButtonStyle()).frame(width: 0, height: 0).hidden()

                Button(action:{self.isActive = true}, label:{Image(systemName: "message")}).buttonStyle(BorderlessButtonStyle()).frame(maxWidth: .infinity)
                NavigationLink(destination: ChatLogView(chatLogVM:ChatLogVM(receiverId: postVM.post.posterId)),
                               isActive: $isActive){EmptyView()}
                               .buttonStyle(BorderlessButtonStyle()).frame(width: 0, height: 0).hidden()
            }
        }.sheet(isPresented: $postVM.showModal) {
            PostEditModal(postVM: postVM, locationService: LocationService())
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        let postVM = PostVM(post: Post.dummyPost)
        PostView(postVM: postVM)
    }
}

struct tagSectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .padding(.horizontal, 14)
            .padding(.vertical)
            .background(
                Capsule().fill(Color.lightOrange)
            )
            .lineLimit(1)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        let postVM = PostVM(post: Post.dummyPost)
        CommentView(post: postVM.post)
    }
}
