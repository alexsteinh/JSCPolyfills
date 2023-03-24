//
//  Headers.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

@objc private protocol HeadersExport: JSExport {
    init(headers: JSValue)
    
//    func append(_ name: String, _ value: String)
    func delete(_ name: String)
    func entries() -> [[String]]
//    func forEach() ->
    func get(_ name: String) -> String?
    func has(_ name: String) -> Bool
    func keys() -> [String]
    func set(_ name: String, _ value: String)
    func values() -> [String]
}

final class Headers: NSObject, HeadersExport {
    private var headers: [String: String]
    
    init(headers: JSValue) {
        if headers.isArray, let array = headers.toArray() {
            self.headers = Self.headers(from: array)
        } else if headers.isObject, let dict = headers.toDictionary() {
            self.headers = Self.headers(from: dict)
        } else {
            self.headers = [:]
        }
    }
    
    init(dict: [AnyHashable: Any]) {
        headers = Self.headers(from: dict)
        super.init()
    }
    
    private static func headers(from dict: [AnyHashable: Any]) -> [String: String] {
        let entries = Array(dict).compactMap { (key: AnyHashable, value: Any) -> (String, String)? in
            guard let key = key as? String, let value = value as? String else {
                return nil
            }
            
            return (key, value)
        }
        
        return Dictionary(uniqueKeysWithValues: entries)
    }
    
    private static func headers(from array: [Any?]) -> [String: String] {
        let entries = array.compactMap { element -> (String, String)? in
            guard let element = element as? [String], element.count == 2 else {
                return nil
            }
            
            return (element[0], element[1])
        }
        
        return Dictionary(uniqueKeysWithValues: entries)
    }
    
    static var empty: Headers {
        .init(dict: [:])
    }
    
    func delete(_ name: String) {
        headers.removeValue(forKey: name)
    }
    
    func entries() -> [[String]] {
        headers.map { [$0, $1] }
    }
    
    func dict() -> [String: String] {
        headers
    }
    
    func get(_ name: String) -> String? {
        headers[name]
    }
    
    func has(_ name: String) -> Bool {
        headers.keys.contains(name)
    }
    
    func keys() -> [String] {
        Array(headers.keys)
    }
    
    func set(_ name: String, _ value: String) {
        headers[name] = value
    }
    
    func values() -> [String] {
        Array(headers.values)
    }
    
    func clone() -> Headers {
        .init(dict: headers)
    }
}
