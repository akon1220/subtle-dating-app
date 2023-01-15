//
//  FeedView.swift
//  subtle
//
//  Created by Shufan Wen on 3/4/22.
//

import SwiftUI

struct FeedView: View {

    @ObservedObject var feedVM: FeedVM
    
    var body: some View {
        VStack{
        HStack{
            
                           VStack {
                               HStack {
                                   HStack {
                                       Image(systemName: "magnifyingglass")
                                       TextField("search", text: $feedVM.searchText,  onCommit: {
                                           print("onCommit")
                                       }).foregroundColor(.primary)
                                       Button(action: {
                                           feedVM.searchText = ""
                                       }) {
                                           Image(systemName: "xmark.circle.fill").opacity(feedVM.searchText == "" ? 0 : 1)
                                       }
                                   }
                                   .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                                   .foregroundColor(.secondary)
                                   .background(Color(.secondarySystemBackground))
                                   .cornerRadius(10.0)
                                   
                                 
                               }
                               .padding(.horizontal)
                }
            Button(action:{feedVM.loadPosts()}, label:{Image(systemName: "arrow.clockwise.circle")}).buttonStyle(BorderlessButtonStyle())
            Button(action:{ feedVM.showFilterModal = true}, label:{Image(systemName: "line.3.horizontal.decrease.circle")}).buttonStyle(BorderlessButtonStyle())
        }.padding()
            Button("+ make a post") {
                feedVM.showModal = true
            }
            List {
                if (feedVM.searchedPosts.isEmpty) {

                    Text("No posts to show")
                }
                ForEach(feedVM.searchedPosts) { post in
                    PostView(postVM: PostVM(post: post))
                        .padding()
                        .border(Color.black, width: 2)
                        .listRowSeparator(.hidden)
                        .deleteDisabled(post.posterId != FirebaseManager.shared.currentUser?.id)
                }.onDelete(perform: delete)
            }
        }.sheet(isPresented: $feedVM.showModal) {
            PostFormModal(feedVM: feedVM, postFormVM: PostFormVM(), locationService: LocationService())
        }.sheet(isPresented: $feedVM.showFilterModal) {
            FilterFormModal(feedVM: feedVM, filterFormVM: FilterFormVM())
        }
    }
    
    func delete(at offsets: IndexSet) {
        let offsetList = Array(offsets)
        let deletePosts = offsetList.map({ idx in
            return feedVM.posts[idx]
        })
        deletePosts.forEach({ post in
            feedVM.deletePost(post: post)
        })
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        let feedVM = FeedVM()
        FeedView(feedVM: feedVM)
    }
}
