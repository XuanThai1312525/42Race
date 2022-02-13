//
//  HomeViewModel.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 09/02/2022.
//

import Foundation
import RxSwift

class HomeViewModel {
    var requestor: APIRequestable
    private var business: [Business] = [Business]()
    private var displayBusiness: [Business] {
        switch sortType {
        case .distance:
            return business.sorted(by: {$0.distance < $1.distance})
        case .rating:
            return business.sorted(by: {$0.rating ?? 0 > $1.rating ?? 0})
        default:
            return business
        }
    }
    private let bag = DisposeBag()
    let reloadSubject = PublishSubject<Bool>()
    
    var sortType: SortType = .none {
        didSet {
            reloadSubject.onNext(true)
        }
    }
    
    enum SortType {
        case none ,distance, rating
    }

    var numberOfItems: Int {
        return displayBusiness.count
    }
    
    init(requestor: APIRequestable) {
        self.requestor = requestor
    }
    
    func itemAtIndex(_ index: Int) -> Business {
        return displayBusiness[index]
    }
    
    func getBusiness(name: String, location: String, type: String) {
        requestor.getBusiness(name: name, location: location, type: type).asObservable().observe(on: MainScheduler.asyncInstance).subscribe {[weak self] business in
            guard let _self = self else {return}
            _self.business = business
            _self.reloadSubject.onNext(true)
        } onError: { error in
            
        }.disposed(by: bag)
    }
}
