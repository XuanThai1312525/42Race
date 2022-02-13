//
//  StringExtension.swift
//  MyVIB_2.0_Keyboard
//
//  Created by Hưng Phan on 28/11/2021.
//

import Foundation

extension String {
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    
    var asData: Data? {
        data(using: .utf8)
    }
    
    func asData(_ encoding: String.Encoding) -> Data? {
        data(using: encoding)
    }
   
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }

        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func getCleanedURL() -> URL? {
        guard self.isEmpty == false else {
            return nil
        }
        let strUrl = removeAllSpace()
        if let url = URL(string: strUrl) {
            return url
        } else {
            if let urlEscapedString = strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) , let escapedURL = URL(string: urlEscapedString){
                return escapedURL
            }
            
        }
        return nil
    }
    
    func removeAllSpace() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines).joined()
    }
}

extension Optional where Wrapped == String {
    var unwrap: String {
        return self ?? ""
    }
}

extension Optional where Wrapped == Int {
    var unwrap: Int {
        return self ?? 0
    }
}

extension Dictionary {
    func convertToString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            if let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return json as String
            }
            return ""
        } catch {
            return ""
        }
    }
}

extension Array{
    func convertToString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            if let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return json as String
            }
            return ""
        } catch {
            return ""
        }
    }
}

extension Dictionary {
    var asString: String {
        guard let profileData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) else {return ""}
        return profileData.asString
    }
    
    var asData: Data? {
        return try? JSONSerialization.data(withJSONObject: self)
    }
}
