//
//  PostFormModal.swift
//  subtle
//
//  Created by Shufan Wen on 3/8/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostFormModal: View {
    
//    @State private var name = ""
//    @State private var date = Date()
//    @State private var university = ""
//    @State private var location = " "
//    @State private var text = ""
    @State private var tags: [String] = []
    @State private var tagText: String = ""
    @State private var showAlert : Bool = false
//    @State private var images: [UIImage] = []
    @State private var showPhotoLibrary = false
    @ObservedObject var feedVM: FeedVM
    @ObservedObject var postFormVM: PostFormVM
    @ObservedObject var locationService: LocationService
    
    var bindingForImage: Binding<UIImage> {
        Binding<UIImage> { () -> UIImage in
            return postFormVM.images.last ?? UIImage()
        } set: { image in
            postFormVM.images.append(image)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $postFormVM.name)
                        .listRowSeparator(.hidden)
                    if postFormVM.nameError {
                        Text("Please enter a name!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("Birth Date")) {
                    DatePicker(
                        "Birth Date",
                        selection: $postFormVM.date,
                        displayedComponents: [.date]
                    )
                    if postFormVM.birthdateError {
                        Text("Please enter a valid birthday! The friend being auctioned should be between 18-30 years old.")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("University")) {
                    Picker("University", selection: $postFormVM.university) {
                        ForEach(postFormVM.universityList, id: \.self) {
                            Text($0)
                        }
                    }
                    if postFormVM.universityError {
                        Text("Please select a university!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                .task { await postFormVM.getUniversities() }
                
                Section(header: Text("Location")) {
                    ZStack(alignment: .trailing) {
                        TextField("Search", text: $locationService.queryFragment)
                            .listRowSeparator(.hidden)
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
                        Picker("Location", selection: $postFormVM.location) {
                            ForEach(locationService.searchResults, id: \.self) { completionResult in
                                Text(completionResult)
                            }
                        }.pickerStyle(.inline)
                            .labelsHidden()
                    default:
                        EmptyView()
                    }
                    if postFormVM.location != "" {
                        HStack {
                            Text("Location")
                            Spacer()
                            Text(postFormVM.location)
                        }
                    }
                    if postFormVM.locationError {
                        Text("Please enter a location!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Section(header: Text("Tell Us About Your Friend")) {
                    TextEditor(text: $postFormVM.text).frame(height: 200)
                        .listRowSeparator(.hidden)
                    if postFormVM.textError {
                        Text("Please tell us about the friend you are auctioning!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                
                Section(header: Text("Tags")) {
                    
                    //Custom Tag View...
                    TagView(maxLimit: 100, tags: $tags)
                    //Default Height...
                        .frame(height: 200)
                    
                    TextField("tag here", text: $tagText)
                        .font(.title3)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    
                    Button{
                        //Adding Tag..
                            tags.append(tagText)
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
                Section(header: Text("Add Images")) {
                    Button("Add an Image") {
                        self.showPhotoLibrary = true
                    }.sheet(isPresented: $showPhotoLibrary) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage : bindingForImage)
                    }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(postFormVM.images, id: \.self) { image in
                                Button(action: {
                                    let idx = postFormVM.images.firstIndex(where:{$0.hashValue == image.hashValue})
                                    if let idx = idx {
                                        postFormVM.images.remove(at:idx)
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
                    if postFormVM.imagesError {
                        Text("Please select at least one image!")
                            .foregroundColor(Color.red)
                            .font(.caption)
                            .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                    }
                }
                Button("Submit Form") {
                    postFormVM.submitForm()
                    if postFormVM.postFormIsValid() {
                        formCompletion()
                        feedVM.showModal = false
                    }
                }
            }.navigationBarTitle("Auction Off Your Friend")
             .navigationBarItems(trailing:Button("Cancel"){
                 feedVM.showModal = false
             })
            //maybe wrong place
             .alert(isPresented: $showAlert) {
                 Alert(title: Text("Error"), message: Text("Tag Limit Exceeded  try to delete some tags !!"), dismissButton: .destructive(Text("Ok")))
             }
        }
    }
    
    func formCompletion() {
        guard let user = FirebaseManager.shared.currentUser else {
            print("Error current user is nil")
            return
        }
        guard let userId = user.id else {
            print("Error current user has nil id")
            return
        }
        let post = Post(
            posterId : userId,
            name : postFormVM.name,
            university: postFormVM.university,
            location: postFormVM.location,
            birthday: postFormVM.date,
            text: postFormVM.text,
            tags: tags
        )
        feedVM.addPostAndImages(post: post, images: postFormVM.images)
    }
}

struct PostFormModal_Previews: PreviewProvider {
    static var previews: some View {
        let feedVM = FeedVM()
        PostFormModal(feedVM: feedVM, postFormVM: PostFormVM(), locationService: LocationService())
    }
}
