//
//  FilterFormVM.swift
//  subtle
//
//  Created by Karoline Xiong on 4/8/22.
//


import Foundation
import Combine
import SwiftUI

class FilterFormVM: ObservableObject {
    //List of colleges in the US
    @Published var universityList: [String] = ["loading universities"]
    
    func getUniversities() async {
        do {
            let response = try await CollegeAPIService.fetch()
            self.universityList = response
        } catch {
            self.universityList = ["\(error)"]
        }
        
    }
}
