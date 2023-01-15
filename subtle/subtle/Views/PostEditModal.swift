//
//  PostEditModal.swift
//  subtle
//
//  Created by Shufan Wen on 3/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostEditModal: View {
    
    @ObservedObject var postVM: PostVM
    @ObservedObject var locationService: LocationService
    @State private var showPhotoLibrary = false
    @State private var showAlert: Bool = false
    @State private var tagText: String = ""
    
    var bindingForUIImage: Binding<UIImage> {
        Binding<UIImage> { () -> UIImage in
            return postVM.additionalImages.last ?? UIImage()
        } set: { image in
            postVM.additionalImages.append(image)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $postVM.editName)
                }
                Section(header: Text("Birth Date")) {
                    DatePicker(
                        "Birth Date",
                        selection: $postVM.editDate,
                        displayedComponents: [.date]
                    )
                }
                Section(header: Text("University")) {
                    Picker("University", selection: $postVM.editUniversity) {
                        ForEach(postVM.universityList, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .task { await postVM.getUniversities() }
                Section(header: Text("Location")) {
                    ZStack(alignment: .trailing) {
                        TextField("Search", text: $locationService.queryFragment)
                        // This is optional and simply displays an icon during an active search
                        if locationService.status == .isSearching {
                            Image(systemName: "clock")
                                .foregroundColor(Color.gray)
                        }
                    }
                    switch locationService.status {
                    case .noResults:
                        Text("No Results")
                            .foregroundColor(.gray)
                    case .error(let description): Text("Error: \(description)")
                            .foregroundColor(.red)
                    case .result:
                        Picker("Location", selection: $postVM.editLocation) {
                            ForEach(locationService.searchResults, id: \.self) { completionResult in
                                Text(completionResult)
                            }
                        }.pickerStyle(.inline)
                            .labelsHidden()
                    default:
                        EmptyView()
                    }
                    if postVM.editLocation != "" {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(postVM.editLocation)
                        }
                    }
                }
                Section(header: Text("Tell Us About Your Friend")) {
                    TextEditor(text: $postVM.editText).frame(height: 200)
                }
                Section(header: Text("Tags")) {
                    
                    //Custom Tag View...
                    TagView(maxLimit: 100, tags: $postVM.editTag)
                    //Default Height...
                        .frame(height: 200)
                    
                    TextField("tag here", text: $tagText)
                        .font(.title3)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    
                    Button{
                        //Adding Tag...
                        postVM.editTag.append(tagText)
                        tagText = ""

                    } label: {
                        Text("Add Tag")
                            .fontWeight(.semibold)
//                            .padding(.vertical, 15)
//                            .padding(.horizontal, 45)
//                            .cornerRadius(10)
                    }
                    .disabled(tagText == "")
                    .opacity(tagText == "" ? 0.6 : 1)
                    
                }
                Section(header: Text("Delete Old Images")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(postVM.editImages, id: \.self) { url in
                                Button(action: {
                                    if postVM.selected.contains(url) {
                                        postVM.selected.remove(url)
                                    } else {
                                        postVM.selected.insert(url)
                                    }
                                }) {
                                    Group {
                                        WebImage(url: url)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                    }.overlay(postVM.selected.contains(url) ? Rectangle()                .foregroundColor(Color.blue.opacity(0.3)) : nil)
                                }
                            }
                        }
                    }
                    Button("Delete Selected Images") {
                        postVM.deleteImages()
                    }
                }
                Section(header: Text("Add Additional Images")) {
                    Button("Add Image") {
                        self.showPhotoLibrary = true
                    }.sheet(isPresented: $showPhotoLibrary) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage : bindingForUIImage)
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(postVM.additionalImages, id: \.self) { image in
                                Button(action: {
                                    let idx = postVM.editImages.firstIndex(where:{$0.hashValue == image.hashValue})
                                    if let idx = idx {
                                        postVM.editImages.remove(at:idx)
                                    }
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                }
                            }
                        }
                    }
                }
                Button("Save Changes") {
                    postVM.editPostAndImages()
                    postVM.showModal = false
                }
            }.navigationBarTitle("Edit Your Post")
        }
    }
}

struct PostEditModal_Previews: PreviewProvider {
    static var previews: some View {
        let postVM = PostVM(post: Post.dummyPost)
        PostEditModal(postVM: postVM, locationService: LocationService())
    }
}
