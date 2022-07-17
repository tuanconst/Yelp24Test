//
//  Business.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import Foundation

struct BusinessSearchParametersEncodable: Encodable {
    let term: String
    let location: String
}

struct BusinessSearchResult: Codable {
    
    let total: Int?
    let businesses: [Business]?
}

class Business: Codable {
    
    let id: String?
    let name: String?
    let imageURL: String?
    let rating: Double?
    let categories: [BusinessCategory]?
    let hours: [BusinessHours]?
    let location: BusinessLocation?
    
    
    private enum CodingKeys : String, CodingKey {
        case id, name, imageURL = "image_url", rating, categories, hours, location
    }
}

class BusinessCategory: Codable {
    
    let alias: String?
    let title: String?
    
    private enum CodingKeys : String, CodingKey {
        case alias, title
    }
}

class BusinessHours: Codable {
    
    let isOpenNow: Bool
    
    private enum CodingKeys : String, CodingKey {
        case isOpenNow = "is_open_now"
    }
}

class BusinessLocation: Codable {
    
    let displayAddress: [String]?
    
    private enum CodingKeys : String, CodingKey {
        case displayAddress = "display_address"
    }
}
