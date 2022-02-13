//
//  NSData+Extensions.swift
//  MyVIBKeyboard
//
//  Created by Thai Nguyen on 12/3/21.
//

import Foundation
extension Optional where Wrapped == Data {
    var unwrap: Data {
        return self ?? Data()
    }
}

extension Data {
    var asUInt8: UInt8 {
        get {
            var number: UInt8 = 0
            copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    var asUInt32: UInt32 {
        get {
            return withUnsafeBytes { $0.load(as: UInt32.self) }
        }
    }
    
    var asJSON: Any? {
        return try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments)
    }
    
    var asString: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
    
    func toModel<T: Decodable>(_ type: T.Type) -> T? {
        let decoder = JSONDecoder()
        var model: T?
        do {
            model = try decoder.decode(T.self, from: self)
        }
        catch {
            print("Failed to parse \(String(describing: T.self)) - error: \(error)")
        }
        return model
    }

}

extension Data {
    var asArray: [Any] {
        return (try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? [Any]) ?? []
    }
}

extension Int {
    var asInt32: Int32 {
        return Int32(self)
    }
}

