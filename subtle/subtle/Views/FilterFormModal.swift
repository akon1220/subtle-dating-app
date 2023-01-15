//
//  FilterFormModal.swift
//  subtle
//
//  Created by Karoline Xiong on 4/8/22.
//
import SwiftUI
import SDWebImageSwiftUI

struct FilterFormModal: View {
    
    @State private var date = Date()
    @State private var university = ""
    @ObservedObject var feedVM: FeedVM
    @ObservedObject var filterFormVM: FilterFormVM
    @State private var minAge = 18.0
    @State private var maxAge = 30.0
    @State private var isEditingMin = false
    @State private var isEditingMax = false
    @State private var showingAlert = false
    @State var dialogErrorMsg: String? = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Minimum Age")) {
                    Slider(
                            value: $minAge,
                            in: 18...30,
                            step: 1
                        ) {
                            Text("Minimum age:")
                        } minimumValueLabel: {
                            Text("18")
                        } maximumValueLabel: {
                            Text("30")
                        } onEditingChanged: { editing in
                            isEditingMin = editing
                        }
                        Text("\(Int(minAge))")
                            .foregroundColor(isEditingMin ? .red : .blue)
                }
                Section(header: Text("Maximum Age")) {
                    Slider(
                            value: $maxAge,
                            in: 18...30,
                            step: 1
                        ) {
                            Text("Maximum age:")
                        } minimumValueLabel: {
                            Text("18")
                        } maximumValueLabel: {
                            Text("30")
                        } onEditingChanged: { editing in
                            isEditingMax = editing
                        }
                        Text("\(Int(maxAge))")
                            .foregroundColor(isEditingMax ? .red : .blue)
                }
        
            
                Section(header: Text("University")) {
                    Picker("University", selection: $university) {
                        ForEach(filterFormVM.universityList, id: \.self) {
                            Text($0)
                        }
                    }
                }.padding()
                .task { await filterFormVM.getUniversities() }
                
                
                 HStack{
                     Text("Apply Filters").frame(width: 300).onTapGesture {
                         if minAge > maxAge {
                             showingAlert = true
                             dialogErrorMsg = "minimum age cannot be greater than maximum age"
                         }else {
                             onSubmit()
                             feedVM.showFilterModal = false
                         }
                 }.alert(isPresented: $showingAlert, content: {
                     Alert(title: Text("Error"), message: Text(dialogErrorMsg!), dismissButton: .default(Text("Got it!")))

                 })
                 }
            }.navigationBarTitle("Filter by: ")
             .navigationBarItems(trailing:Button("Cancel"){
                 feedVM.showFilterModal = false
             })
        }
                       }
    
    func onSubmit() {
        guard let user = FirebaseManager.shared.currentUser else {
            print("Error current user is nil")
            return
        }
       feedVM.loadFilteredPosts(uniQuery: university, minAgeQuery: minAge, maxAgeQuery: maxAge)
    }

}


struct FilterFormModal_Previews: PreviewProvider {
    static var previews: some View {
        let feedVM = FeedVM()
        FilterFormModal(feedVM: feedVM, filterFormVM: FilterFormVM())
    }
}
