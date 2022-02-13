//
//  AppService.swift
//  AnonymousChat
//
//  Created by Tung Nguyen on 11/17/19.
//  Copyright © 2019 Nguyễn Quốc Tùng. All rights reserved.
//

import Foundation
import UIKit

class SuccessModel: Codable {
    let message: String
    var code: Int = 200

    private enum CodingKeys: String, CodingKey {
        case message
        case code
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        message = container.decode(.message, defaultValue: "")
        message = ""
    }
}

// MARK: - Welcome
final class IssuesResponse: Codable {
    let issues: [Issue]

    init(issues: [Issue]) {
        self.issues = issues
    }
}

// MARK: - Issue
final class Issue: Codable {
    let severity, code, details: String

    init(severity: String, code: String, details: String) {
        self.severity = severity
        self.code = code
        self.details = details
    }
}


protocol AppRequestType {}

protocol AsServiceHost {
    var host: String {get set}
    var appToken: String {get set}
    var platformToken: String {get set}
}

protocol AsCommonService: AsService {
    var authenHeader: Header {get}
}

extension AsCommonService {
    var authenHeader: Header {
        return Header().add(.authorization(.bearer(service.platformToken)))
        //return Header().add(.authorization(.token(platformToken)))
    }
}

extension AsService where Self: AsCommonService {
    func headerFor(_ type: AppRequestType) -> Header {
        return Header().add(.accept(.appJSON))
            .add(.contentType(.appJSON))
            .merge(authenHeader)
    }
}

protocol AsService: AnyObject {
    var service: AsServiceHost {get}
    var host: String {get}
    var appToken: String {get}
    var platformToken: String {get}
    
    func headerFor(_ type: AppRequestType) -> Header
    func bodyFor(_ type: AppRequestType) -> Data?
    func urlPathFor(_ type: AppRequestType) -> String
    func methodFor(_ type: AppRequestType) -> RequestMethod
    func queryParams(_ type: AppRequestType) -> [String: String]?
//    func executeRequest(_ type: AppRequestType, completion: ((JSON?, Int, Error?) -> Void)?)
    func didRequest(_ type: AppRequestType, error: Error?)
    func didGetModel(_ type: AppRequestType, model: SuccessModel?)
    func isSuccess(_ code: Int) ->Bool
}

private var kServiceInternalQueue: UInt8 = 0
extension AsService {
    var internalQueue: DispatchQueue {
        get {
            var queue = objc_getAssociatedObject(self, &kServiceInternalQueue) as? DispatchQueue
            if queue == nil {
                queue = DispatchQueue(label: "remoteservice.internal")
                self.internalQueue = queue!
            }
            return queue!
        }
        set {
            objc_setAssociatedObject(self, &kServiceInternalQueue, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var service: AsServiceHost {
        return AppServiceHost.shared
    }
    
    var host: String {
        return service.host
    }
    
    var appToken: String {
        return service.appToken
    }
    
    var platformToken: String {
        return service.platformToken
    }
    
    func headerFor(_ type: AppRequestType) -> Header {
        return Header().add(.contentType(.appJSON))
    }
    
    func bodyFor(_ type: AppRequestType) -> Data? {
        return nil
    }
    
    func requestFor(_ type: AppRequestType) -> URL {
        let url = "\(host)/\(urlPathFor(type))".asUrl
        assert(url != nil, "url is nil")
        return url!
    }
    
    func methodFor(_ type: AppRequestType) -> RequestMethod {
        return .get
    }
    
    func queryParams(_ type: AppRequestType) -> [String: String]? {
        return nil
    }
    
    func executeRequest(_ type: AppRequestType, completion: ((Data?, Int, Error?) -> Void)?) {
        MyRequestOperation(requestFor(type))
            .method(methodFor(type))
            .headers(headerFor(type).value)
            .postData(bodyFor(type))
            .queryParams(queryParams(type))
            .execute { (data, errors, op) in
            // handle business error if needed
                completion?(data, 200, errors?.first)
        }
    }
    
    
    func makeIssuesModel<T: IssuesResponse>(_ data: Data?, type: T.Type, code: Int) -> (T?) {
        let model = data?.toModel(type)
        return model
     
    }
    
    ///check error code is success or false
    func isSuccess(_ code: Int) ->Bool {
        switch code {
        case 200,201:
            return true
        default:
            return false
        }
    }
    
    func didRequest(_ type: AppRequestType, error: Error?) {}
    func didGetModel(_ type: AppRequestType, model: SuccessModel?) {}

}

struct ServiceError: Error {
    let message: String
    let code: Int
    let issueCode: String
}

enum ResponseError: Error {
    case noInternet
    case serverError
    case unknown
    case authentication
    case decodeFailure
    case detailError(String)
}

class AppServiceHost: AsServiceHost {
    static let shared = AppServiceHost()
    var host = "https://api.yelp.com/v3/businesses"
    var appToken = ""
    var platformToken = ""
}

extension String {
    var asImage: UIImage? {
        return UIImage(named: self)
    }
    
    var asUrl: URL? {
        return URL(string: self)
    }
}
