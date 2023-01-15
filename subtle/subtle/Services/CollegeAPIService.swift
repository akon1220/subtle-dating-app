//
//  CollegeAPIService.swift
//  subtle
//
//  Created by Jenny Li on 3/19/22.
//

import Foundation

struct CollegeAPIService: Hashable {
    static let url = "http://universities.hipolabs.com/search?country=United%20States"
    
    static func fetch() async throws -> [String] {
        let responseData: [CollegeAPIResponse] = try await RestAPIClient().performRequest(url: url)
        let colleges = responseData.map { $0.name }
        return Array(Set(colleges)).sorted() // API data now has duplicates for some reason
    }
    
    static func fetchColleges() async throws -> [College] {
        print("FETCHING COLLEGES!")
        let responseData: [CollegeAPIResponse] = try await RestAPIClient().performRequest(url: url)
        let colleges = responseData.map { College(name: $0.name, domain: $0.domains[0]) }
        //let uniqueColleges = Set(colleges)
        return Array(Set(colleges)).sorted(by: {$0.name < $1.name}) // API data now has duplicates for some reason
    }
}

struct CollegeAPIResponse: Decodable {
    let name: String
    let domains: [String]
}
