//
//  HomeModels.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 11/02/2022.
//

import Foundation

struct BusinessResponse: Codable {
    var businesses: [Business]
}

struct Category: Codable {
    var alias: String
    var title: String
}

struct Location: Codable {
    var displayAddress: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}

struct Business: Codable {
    let id: String
    let alias: String
    let name: String
    let imageURLString: String
    let isClosed: Bool
    let reviewCount: Int
    let displayPhone: String
    let distance: Double
    let categories: [Category]
    let location: Location?
    let price: String?
    let rating: Float?
    private enum CodingKeys: String, CodingKey {
        case id
        case alias
        case name
        case imageURLString = "image_url"
        case isClosed = "is_closed"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
        case distance
        case categories
        case location
        case price
        case rating
    }
}
