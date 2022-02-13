//
//  MyRequest.swift
//  MyRequestOperation
//
//  Created by Thai Nguyen on 10/3/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DEL"
}

enum ImageType {
    case png
    case jpeg(_ quality: CGFloat)
    case unknown
    
    var rawValue: String {
        switch self {
        case .png:
            return "PNG"
            
        case .jpeg(_):
            return "JPEG"
            
        default:
            return ""
        }
    }
    
    var mimeType: String {
        switch self {
        case .jpeg(_):
            return "image/jpeg"
            
        case .png:
            return "image/png"
            
        default:
            return ""
        }
    }
}

enum MyError: Error {
    case invalidUrl
    case invalidImageData
    case parseDataFail
    case dataNil
    case none
}

enum HeaderValue {
    case bearer(_ token: String)
    case token(_ token: String)
    case appJSON
    case multipart(_ boundary: String)
    case formUrlencoded
    
    var value: String {
        switch self {
        case let .bearer(token):
            return "Bearer \(token)"
            
        case let .token(token):
            return token
            
        case .appJSON:
            return "application/json"
            
        case .formUrlencoded:
            return "application/x-www-form-urlencoded"
            
        case let .multipart(boundary):
            return "multipart/form-data; boundary=\(boundary)"
        }
    }
}

enum HeaderKey {
    case authorization(_ value: HeaderValue)
    case contentType(_ value: HeaderValue)
    case accept(_ value: HeaderValue)
    case none
    
    var value: [String: String] {
        switch self {
        case let .authorization(type):
            if type.value.isEmpty {
                return [:]
            }else{
                return ["Authorization": type.value]
            }
        case let .contentType(type):
            return ["Content-Type" : type.value]
            
        case let .accept(type):
            return ["Accept" : type.value]
            
        default:
            return [:]
        }
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        dict.forEach({ updateValue($0.value, forKey: $0.key) })
    }
}

final class Header {
    var headers: [String: String] = [:]
    func add(_ type: HeaderKey) -> Header {
        headers.merge(dict: type.value)
        return self
    }
    
    func merge(_ header: Header) -> Header {
        headers.merge(dict: header.value)
        return self
    }
    
    func remove(_ type: HeaderKey) -> Header {
        if let key = type.value.keys.first {
            headers.removeValue(forKey: key)
        }
        return self
    }
    
    func add(_ header: [String: String]) -> Header {
        headers.merge(dict: header)
        return self
    }
    
    var value: [String: String] {
        return headers
    }
}

final class MyRequestOperation: AsOperation {
    var sessionConfiguration = URLSessionConfiguration.ephemeral
    var sessionDelegate: URLSessionDelegate?
    var sessionDelegateQueue: OperationQueue?
    var requestMethod = RequestMethod.get
    var cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    var timeout = 60.0
    var secondaryTimeout = 30.0
    var headers: [String: String] = [:]
    var postBody: Data?
    var retryTimes = 3
    var shouldRequestAsynchronously = true
    var queryParams: [String: String]?
    var requestConfiguration: MyRequestConfiguration?
    
    private(set) var urlRequest: URLRequest?
    private(set) var errors: [Error]?
    private(set) var response: URLResponse?
    private(set) var callStack: [String] = []
    
    private var synchronousRequestSemaphore: DispatchSemaphore?
    private var responseData: Data?
    
    var operationId = UUID().uuidString
    typealias MyRequestCompletion = ((Data?, [Error]?, MyRequestOperation) -> Void)
    
    convenience init(_ url: String) {
        self.init()
        if let anURL = URL(string: url) {
            urlRequest = URLRequest(url: anURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
        } else {
            appendError(MyError.invalidUrl)
        }
    }
    
    convenience init(_ url: URL) {
        self.init()
        urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
    }
    
    private func appendError(_ error: Error) {
        if errors == nil {
            errors = []
        }
        errors!.append(error)
    }
    
    func requestConfiguration(_ config: MyRequestConfiguration?) -> MyRequestOperation {
        requestConfiguration = config
        return self
    }
    
    func sessionConfiguration(_ sessionConfig: URLSessionConfiguration) -> MyRequestOperation {
        sessionConfiguration = sessionConfig
        return self
    }
    
    func sessionDelegate(_ delegate: URLSessionDelegate?) -> MyRequestOperation {
        sessionDelegate = delegate
        return self
    }
    
    func sessionDelegateQueue(_ queue: OperationQueue?) -> MyRequestOperation {
        sessionDelegateQueue = queue
        return self
    }
    
    func cachePolicy(_ policy: URLRequest.CachePolicy) -> MyRequestOperation {
        cachePolicy = policy
        return self
    }
    
    func timeoutInterval(_ timeoutInterval: TimeInterval) -> MyRequestOperation {
        timeout = timeoutInterval
        return self
    }
    
    func secondaryTimeoutInterval(_ secTimeoutInterval: TimeInterval) -> MyRequestOperation {
        secondaryTimeout = secTimeoutInterval
        return self
    }
    
    func retryTimes(_ retry: Int) -> MyRequestOperation {
        retryTimes = retry
        return self
    }
    
    func method(_ method: RequestMethod) -> MyRequestOperation {
        requestMethod = method
        return self
    }
    
    func headers(_ requestHeaders: [String: String]) -> MyRequestOperation {
        print("======= Header: \(requestHeaders)")
        requestHeaders.forEach({ headers[$0.key] = $0.value })
        return self
    }
    
    func queryParams(_ params: [String: String]?) -> MyRequestOperation {
        queryParams = params
        return self
    }
    
    func postData(_ data: Data?) -> MyRequestOperation {
        postBody = data
        return self
    }
    
    func shouldRequestAsynchronously(_ requestAsync: Bool) -> MyRequestOperation {
        shouldRequestAsynchronously = requestAsync
        return self
    }
    
    private func applyConfig() {
        guard let requestConfiguration = requestConfiguration else {return}
        requestMethod = requestConfiguration.requestMethod
        sessionConfiguration = requestConfiguration.sessionConfiguration
        sessionDelegate = requestConfiguration.sessionDelegate
        sessionDelegateQueue = requestConfiguration.sessionDelegateQueue
        cachePolicy = requestConfiguration.cachePolicy
        timeout = requestConfiguration.timeout
        secondaryTimeout = requestConfiguration.secondaryTimeout
        headers = requestConfiguration.headers
        postBody = requestConfiguration.postBody
        retryTimes = requestConfiguration.retryTimes
        shouldRequestAsynchronously = requestConfiguration.shouldRequestAsynchronously
    }
    
    func execute(_ completion: MyRequestCompletion?) {
        guard errors == nil else {
            print("MyRequest - Errors: \(String(describing: errors))")
            completion?(nil, errors, self)
            return
        }
        
        MyRequestManager.shared.cacheOperation(self)
        
        callStack = Thread.callStackSymbols
        
        // apply configuration
        applyConfig()
        
        // add headers
        headers.forEach({ urlRequest?.addValue($0.value, forHTTPHeaderField: $0.key) })
        // add post body
        urlRequest?.httpBody = postBody
        applyParams()
        // add other fields
        urlRequest?.cachePolicy = cachePolicy
        urlRequest?.timeoutInterval = timeout
        urlRequest?.httpMethod = requestMethod.rawValue
        
        if !shouldRequestAsynchronously {
            synchronousRequestSemaphore = DispatchSemaphore(value: 0)
        }
        
        print("\(urlRequest!.url)")
        executeRequest(completion)
        
        if !shouldRequestAsynchronously {
            synchronousRequestSemaphore?.wait()
            
            // for sync request
            MyRequestManager.shared.removeOperation(self)
            completion?(responseData, errors, self)
        }
    }
    
    
    private func applyParams() {
        guard let queryParams = queryParams else { return }
        if requestMethod == .get {
            if let url = urlRequest?.url {
                let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
                var items = [URLQueryItem]()
                for (key,value) in queryParams {
                    items.append(URLQueryItem(name: key, value: value))
                }
                urlComponents?.queryItems = items
                urlRequest?.url = urlComponents?.url
            }
        }
    }
    
    private func createSession() -> URLSession {
        return URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: sessionDelegateQueue)
    }
    
    private var currentSession: URLSession?
    private func executeRequest(_ completion: MyRequestCompletion?) {
        currentSession = createSession()
        weak var weakSession = currentSession
        currentSession?.dataTask(with: urlRequest!, completionHandler: { [weak self] (data, response, error) in
            guard let _self = self else { return }
            guard let _session = weakSession else {return}
            if let _ = error {
                if _self.retryTimes > 0 {
                    _session.finishTasksAndInvalidate()
                    _self.retryTimes = _self.retryTimes - 1
                    _self.urlRequest?.timeoutInterval = _self.secondaryTimeout
                    _self.executeRequest(completion)
                    return
                }
                else {
                    _self.appendError(error!)
                }
            }
            _self.responseData = data
            _self.response = response
            _session.finishTasksAndInvalidate()
            
            if !_self.shouldRequestAsynchronously {
                _self.synchronousRequestSemaphore?.signal()
            }
            else {
                // for async request
                MyRequestManager.shared.removeOperation(_self)
                completion?(_self.responseData, _self.errors, _self)
            }
        }).resume()
    }
    
    func escape(_ string: String) -> String {
           let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
           let subDelimitersToEncode = "!$&'()*+,;="
           
           var allowedCharacterSet = CharacterSet.urlQueryAllowed
           allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
           
           var escaped = ""
           
           //==========================================================================================================
           //
           //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
           //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
           //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
           //  info, please refer to:
           //
           //      - https://github.com/Alamofire/Alamofire/issues/206
           //
           //==========================================================================================================
           
           if #available(iOS 8.3, *) {
               escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
           } else {
               let batchSize = 50
               var index = string.startIndex
               
               while index != string.endIndex {
                   let startIndex = index
                   let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
                   let range = startIndex..<endIndex
                   
                   let substring = string[range]
                   
                   escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                   
                   index = endIndex
               }
           }
           
           return escaped
       }

    
    deinit {
        print("=== Request Operation DEALLOC ===")
    }
}

final class MyAttachment {
    var boundary = UUID().uuidString
    
    private enum AttachmentType {
        case file(_ path: String)
        case fileData(_ data: Data?)
        case image(_ image: UIImage, type: ImageType)
    }
    
    private struct Attachment {
        var type = AttachmentType.file("")
        var data: Data?
        var fileExtension = ""
        var fileName = ""
        var field = ""
        
        init(_ attType: AttachmentType) {
            type = attType
            switch attType {
            case let .image(image, type: imgType):
                fileExtension = imgType.rawValue.lowercased()
                switch imgType {
                case let .jpeg(quality):
                    data = image.jpegData(compressionQuality: quality)
                    
                case .png:
                    data = image.pngData()
                    
                default: break
                }
                
            case let .fileData(d):
                data = d
                
            case let .file(path):
                let url = URL(fileURLWithPath: path)
                fileExtension = url.lastPathComponent.components(separatedBy: ".").last.unwrap
                fileName = url.lastPathComponent.components(separatedBy: ".").first.unwrap
                data = try? Data(contentsOf: url)
            }
        }
        
        var fileFullName: String {
            return fileName + ".\(fileExtension)"
        }
        
        var contentType: String {
            switch type {
            case .fileData(_), .file(_):
                return "application/" + fileExtension
                
            case let .image(_, type: imgType):
                return imgType.mimeType
            }
        }
    }
    
    private(set) var error = MyError.none
    private var attachments: [Attachment] = []
    
    func boundary(_ b: String) -> MyAttachment {
        boundary = b
        return self
    }
    
    func attach(image i: UIImage, imageName: String, imageType: ImageType, forField fieldName: String = "") -> MyAttachment {
        var att = Attachment(.image(i, type: imageType))
        att.fileName = imageName
        att.field = fieldName
        attachments.append(att)
        return self
    }
    
    func attach(filePath path: String, forField fieldName: String = "") -> MyAttachment {
        var att = Attachment(.file(path))
        att.field = fieldName
        attachments.append(att)
        return self
    }
    
    func attach(fileData f: Data, fileName: String, fileExtension: String, forField fieldName: String = "") -> MyAttachment {
        var att = Attachment(.fileData(f))
        att.fileName = fileName
        att.fileExtension = fileExtension
        att.field = fieldName
        attachments.append(att)
        return self
    }
    
    private func createBody(_ attachment: Attachment) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".asData.unwrap)
        body.append("Content-Disposition:form-data; name=\"\(attachment.field)\"; filename=\"\(attachment.fileFullName)\"\r\n".asData.unwrap)
        body.append("Content-Type: \(attachment.contentType)\r\n\r\n".asData.unwrap)
        body.append(attachment.data.unwrap)
        body.append("\r\n".asData.unwrap)
        return body
    }
    
    func execute() -> Data {
        var finalData = Data()
        attachments.forEach { finalData.append(createBody($0)) }
        finalData.append("--\(boundary)--\r\n".asData.unwrap)
        return finalData
    }
}

protocol AsOperation: AnyObject {
    var operationId: String {get set}
}

final class MyRequestManager {
    static let shared = MyRequestManager()
    var operations: [String: AsOperation] = [:]
    let operationQueue = DispatchQueue.init(label: "com.myrequestmanager.operation")
    func cacheOperation(_ operation: AsOperation) {
        operationQueue.sync { [weak self] in
            guard let _self = self else {return}
            _self.operations[operation.operationId] = operation
        }
    }
    
    func removeOperation(_ operation: AsOperation) {
        operationQueue.sync { [weak self] in
            guard let _self = self else {return}
            _self.operations.removeValue(forKey: operation.operationId)
        }
    }
}

final class MyRequestConfiguration {
    private(set) var requestMethod = RequestMethod.get
    
    var sessionConfiguration: URLSessionConfiguration = .ephemeral
    var sessionDelegate: URLSessionDelegate?
    var sessionDelegateQueue: OperationQueue?
    var cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    var timeout = 60.0
    var secondaryTimeout = 30.0
    var headers: [String: String] = [:]
    var postBody: Data?
    var retryTimes = 3
    var shouldRequestAsynchronously = true
    
    convenience init(_ method: RequestMethod) {
        self.init()
        requestMethod = method
    }
    
    func sessionConfiguration(_ sessionConfig: URLSessionConfiguration) -> MyRequestConfiguration {
        sessionConfiguration = sessionConfig
        return self
    }
    
    func sessionDelegate(_ delegate: URLSessionDelegate?) -> MyRequestConfiguration {
        sessionDelegate = delegate
        return self
    }
    
    func sessionDelegateQueue(_ queue: OperationQueue?) -> MyRequestConfiguration {
        sessionDelegateQueue = queue
        return self
    }
    
    func cachePolicy(_ policy: URLRequest.CachePolicy) -> MyRequestConfiguration {
        cachePolicy = policy
        return self
    }
    
    func timeoutInterval(_ timeoutInterval: TimeInterval) -> MyRequestConfiguration {
        timeout = timeoutInterval
        return self
    }
    
    func secondaryTimeoutInterval(_ secTimeoutInterval: TimeInterval) -> MyRequestConfiguration {
        secondaryTimeout = secTimeoutInterval
        return self
    }
    
    func retryTimes(_ retry: Int) -> MyRequestConfiguration {
        retryTimes = retry
        return self
    }
    
    func headers(_ requestHeaders: [String: String]) -> MyRequestConfiguration {
        requestHeaders.forEach({ headers[$0.key] = $0.value })
        return self
    }
    
    func postData(_ data: Data?) -> MyRequestConfiguration {
        postBody = data
        return self
    }
    
    func shouldRequestAsynchronously(_ requestAsync: Bool) -> MyRequestConfiguration {
        shouldRequestAsynchronously = requestAsync
        return self
    }
}



//extension AsService {
//    func convertValueToBase64ForParam(param: [String: Any], uri: String, isOneLevelSupported: Bool = true) -> [String: Any] {
//        print("======= Params \(param)")
//        if param.count == 0 {
//            return param
//        }
//        var resultDict = [String: Any]()
//        // 1. Endcode uri first
//        let base64OfURI = uri.toBase64() ?? ""
//        for (key, value) in param {
//            if isOneLevelSupported {
//                /*
//                let s = String(describing: value).toBase64() ?? ""
//                let reverseItem = String(s.reversed())
//                let encodeMap = (reverseItem.toBase64() ?? "") + "__" + base64OfURI
//                let lastEncodedVal = encodeMap.toBase64()
//                resultDict[key] = lastEncodedVal
//                */
//                /// Convert into json instead
//                if value is Dictionary<String, Any> {
//                    if let dict = value as? [String: Any]{
//                        let jsonStr = dict.convertToString()
//                        let encodedStr = vibEncodeString(str: jsonStr, by: uri)
//                        resultDict[key] = encodedStr
//                    }
//                    continue
//                }
//
//                if value is Array<Any> {
//                    if let array = value as? [Any]{
//                        let jsonStr = array.convertToString()
//                        let encodedStr = vibEncodeString(str: jsonStr, by: uri)
//                        resultDict[key] = encodedStr
//                    }
//                    continue
//                }
//                // Convert single properties
//                let str = String(describing: value)
//                resultDict[key] = vibEncodeString(str: str, by: uri)
//            } else {
//                if value is Dictionary<String, Any> {
//                    resultDict[key] = convertValueToBase64ForParam(param: value as! [String : Any], uri: uri)
//                    continue
//                }
//                if value is Array<Any> {
//                    var newArr = [Any]()
//                    let arr = value as! Array<Any>
//                    for item in arr {
//                        if item is String {
//                            if let newItem = String(describing: value).toBase64() {
//                                // 2. Reverse value then append with "__"split key
//                                let reverseItem = String(describing: newItem.reversed())
//                                let lastEncodedVal = (reverseItem.toBase64() ?? "") + "__" + base64OfURI
//                                newArr.append(lastEncodedVal)
//                                resultDict[key] = newArr
//                            }
//
//                        }
//                        if item is Dictionary<String, Any> {
//                            if let dict = item as? [String: Any]{
//                                let encodeDict = convertValueToBase64ForParam(param: dict, uri: uri)
//                                //resultDict[key] = convertValueToBase64ForParam(param: dict, uri: uri)
//                                newArr.append(encodeDict)
//                                resultDict[key] = newArr
//                            }
//                        }
//                    }
//                    continue
//                }
//
//                if value is Dictionary<String, Any> {
//                    if let dict = value as? [String: Any]{
//                        let encodeDict = convertValueToBase64ForParam(param: dict, uri: uri)
//                        //resultDict[key] = convertValueToBase64ForParam(param: dict, uri: uri)
//                        resultDict[key] = encodeDict
//                    }
//                    continue
//                }
//                // 3. Same step 2: Add for string, int, double...
//                /*
//                let s = String(describing: value).toBase64() ?? ""
//                let reverseItem = String(s.reversed())
//                let encodeMap = (reverseItem.toBase64() ?? "") + "__" + base64OfURI
//                let lastEncodedVal = encodeMap.toBase64()
//                resultDict[key] = lastEncodedVal
//                */
//                // Convert single properties
//                let str = String(describing: value)
//                resultDict[key] = vibEncodeString(str: str, by: uri)
//            }
//        }
//        print("\(resultDict)")
//        return resultDict
//    }
//
//    private func vibEncodeString(str: String, by uri: String) -> String?{
//        let base64OfURI = uri.toBase64() ?? ""
//        let s = String(describing: str).toBase64() ?? ""
//        let reverseItem = String(s.reversed())
//        let encodeMap = (reverseItem.toBase64() ?? "") + "__" + base64OfURI
//        return encodeMap.toBase64()
//    }
//
//    //
//    // Step to decode data from response key
//    ///
//    /*
//    1. get value của key data ra: T1VwcFNUWkplVmhzZUZkaGFUbFhZbWwzYVVscGIycEpabHBYWVdwS2VXVT1fX1lYQnBMM1Z6WlhKekwyZGxkR04xYzNSdmJXVnk=
//    2. decode value lấy dc bước 2 -> qwerty
//    3. cắt chuỗi bước 3 theo "__" -> abc và def
//    4. decode uri def -> opl
//    5. so sánh opl với uri dưới client xem có giống ko
//    thỏa bước 6, decode tiếp abc -> nml
//    6. đảo ngược mnl -> lnm
//    7. decode lnm -> json data được decode ({cif_:123, mobile_:0978123456}
//    add lại kết quả bước 9 vào key data của json object
//    */
//    func decode(encodedString: String, checkedBy uri: String) -> [String: Any] {
//        if encodedString.isEmpty || uri.isEmpty {return [:]}
//        guard let decodeStep1 = encodedString.fromBase64() else {return [:]}
//        let splitVals = decodeStep1.components(separatedBy: "__")
//        if splitVals.count < 2 {
//            return [:]
//        }
//        if splitVals[1].fromBase64() != uri {
//            return [:]
//        }
//        // Step
//        let valString = splitVals[0]
//        guard let decodeValString = valString.fromBase64() else {return [:]}
//        // let finalResult = String(describing: decodeValString.reversed())
//        let finalResult = String(decodeValString.reversed()).fromBase64() ?? ""
//        return finalResult.toDictionary() ?? [:]
//    }
//}
