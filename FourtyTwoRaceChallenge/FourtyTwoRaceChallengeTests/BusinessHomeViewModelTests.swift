//
//  BusinessHomeViewModelTests.swift
//  FourtyTwoRaceChallengeTests
//
//  Created by ThaiNguyen on 13/02/2022.
//

import XCTest
@testable import FourtyTwoRaceChallenge

class BusinessHomeViewModelTests: XCTestCase {
    var homeCellViewModel: BusinessTableViewModel!
    let business = Business(id: "123", alias: "", name: "Store", imageURLString: "", isClosed: false, reviewCount: 123, displayPhone: "", distance: 12, categories: [], location: nil, price: "12", rating: 1.2)
    
    override func setUp() {
        super.setUp()
        homeCellViewModel = BusinessTableViewModel(business: business)
    }
    
    func testBusinessViewModel() {
        XCTAssertEqual(homeCellViewModel.rating, business.rating)
        XCTAssertEqual(homeCellViewModel.price, business.price)
        XCTAssertEqual(homeCellViewModel.categories, "Categories: \(business.categories.map({$0.title}).joined(separator: ", "))")
    }
}
