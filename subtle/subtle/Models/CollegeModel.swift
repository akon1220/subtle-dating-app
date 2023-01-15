//
//  CollegeModel.swift
//  subtle
//
//  Created by Louise Lu on 3/30/22.
//

import Foundation

struct College: Hashable, Identifiable {
    var id: String {
        self.domain + self.name
    }
    var name: String
    var domain: String
}


extension College {
    
    static let dummyCollege = College(name: "loading universities", domain: "loading.edu")
}
