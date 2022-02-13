//
//  MocAPITest.swift
//  FourtyTwoRaceChallengeTests
//
//  Created by ThaiNguyen on 13/02/2022.
//

import Foundation
@testable import FourtyTwoRaceChallenge
import RxSwift

class MockApiRequestable: APIRequestable {
    var business: [Business] = []
    var token: String = ""
    var reponseTokenError: ResponseError?
    func getBusiness(name: String, location: String, type: String) -> Observable<[Business]> {
        Observable.create {[weak self] observer in
            guard let _self = self else {return Disposables.create()}
            observer.onNext(_self.business)
            return Disposables.create()
        }
    }
    
}
