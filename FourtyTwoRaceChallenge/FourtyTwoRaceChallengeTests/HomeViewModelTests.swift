//
//  HomeViewModelTests.swift
//  FourtyTwoRaceChallengeTests
//
//  Created by ThaiNguyen on 13/02/2022.
//

import XCTest
@testable import FourtyTwoRaceChallenge
import RxSwift

class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockAPI: MockApiRequestable!
    var bag = DisposeBag()
    let business = Business(id: "123", alias: "", name: "Store", imageURLString: "", isClosed: false, reviewCount: 123, displayPhone: "", distance: 12, categories: [], location: nil, price: nil, rating: nil)
    
    override func setUp() {
        super.setUp()
        mockAPI = MockApiRequestable()
        viewModel = HomeViewModel(requestor: mockAPI)
    }
    
    func testGetBusiness() {
        
        mockAPI.business = [business]
        viewModel.reloadSubject.asObserver().subscribe {[weak self] _ in
            let name = self?.viewModel.itemAtIndex(0).name
            XCTAssertEqual(self?.business.name, name)
        } onError: { _ in
            
        }.disposed(by: bag)

        viewModel.getBusiness(name: "", location: "", type: "")
    }
}
