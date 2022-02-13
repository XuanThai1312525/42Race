//
//  BusinessTableViewModel.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 11/02/2022.
//

import Foundation

class BusinessTableViewModel {
    let business: Business
    var imageURL: URL? {
        if let url = URL(string: business.imageURLString) {
            return url
        }
        
        return nil
    }
    
    var name: String {
        business.name
    }
    
    var distance: String {
        String(format: "%@ %0.2f", "Distance:", business.distance)
    }
    
    var categories: String {
        "Categories: \(business.categories.map({$0.title}).joined(separator: ", "))"
    }
    
    var displayPhone: String {
         business.displayPhone
    }
    
    var address: String? {
        business.location?.displayAddress?.first ?? ""
    }
    
    var price: String?{
        business.price
    }
    
    var rating: Float {
        business.rating ?? 0.0
    }
    
    init(business: Business) {
        self.business = business
    }
}
