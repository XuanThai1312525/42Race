//
//  FTRequestService.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 09/02/2022.
//

import Foundation
import RxSwift

enum FTRequestType: AppRequestType {
    case getBusiness(name: String, location: String, type: String)
}

protocol APIRequestable {
    func getBusiness(name: String, location: String, type: String) -> Observable<[Business]>
}

class FTRequestService: APIRequestable {
    private let excuteQueue = DispatchQueue(label: "com.FTproblem.requestservice")
    static let shared = FTRequestService()
    init(){}
    
    func getBusiness(name: String, location: String, type: String) -> Observable<[Business]> {
        Observable.create {[weak self] observer in
            guard let _self = self else {return Disposables.create()}
            _self.executeRequest(FTRequestType.getBusiness(name: name, location: location, type: type)) { [weak _self] data, code, error in
                guard let _self = _self else {return}
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                let results = _self.makeModel(data, type: BusinessResponse.self)
                if let model = results.model {
                    observer.onNext(model.businesses)
                    return
                }
            }
            return Disposables.create()
        }
    }
}

extension FTRequestService {
    func makeModel<T: Decodable>(_ data: Data?, type: T.Type) -> (model: T?, error: ResponseError?) {
        if let model = data?.toModel(type) {
            return (model, nil)
        } else {
            return (nil, ResponseError.decodeFailure)
        }
    }
}

extension FTRequestService: AsService {
    func urlPathFor(_ type: AppRequestType) -> String {
        guard let type = type as? FTRequestType else {return ""}
        switch type {
        case .getBusiness(let name, let location, let type):
            return "search"
        }
    }
    
    func methodFor(_ type: AppRequestType) -> RequestMethod {
        return .get
    }
    
    func headerFor(_ type: AppRequestType) -> Header {
        return Header().add(.authorization(.bearer("ySBdKRebdiNasBkgDRZRO9MoWm76qq0uoUmZocn6O0oVKpX9qmYypHgeoGLAutnoBBtjkED142MJJny9bgsVEx6MegflTBq1EzeXP8YWx74AzCAnGxyk_3w0Ob4DYnYx")))
    }
    
    func bodyFor(_ type: AppRequestType) -> Data? {
        nil
    }
    
    func queryParams(_ type: AppRequestType) -> [String : String]? {
        guard let type = type as? FTRequestType else {return nil}
        switch type {
        case .getBusiness(let name, let location, let type):
            return [
                "term": name,
                "location": location
            ]
        }
    }
}

