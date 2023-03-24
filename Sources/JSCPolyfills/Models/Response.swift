//
//  Response.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

@objc private protocol ResponseExport: JSExport {
    init()
   
    var headers: Headers { get }
    var ok: Bool { get }
    var status: Int { get }
    var url: String { get }
    
    func json() -> JSValue
    func text() -> JSValue
}

final class Response: NSObject, ResponseExport {
    let headers: Headers
    let status: Int
    let url: String
    private let data: Data
    
    var ok: Bool {
        200...299 ~= status
    }
    
    override init() {
        headers = .init(dict: [:])
        status = 200
        url = ""
        data = .init()
        
        super.init()
    }
    
    init(headers: Headers, status: Int, url: String, data: Data) {
        self.headers = headers
        self.status = status
        self.url = url
        self.data = data
        
        super.init()
    }
    
    func clone() -> Response {
        .init(headers: headers.clone(), status: status, url: url, data: data)
    }
    
    func json() -> JSValue {
        .init(newPromiseIn: JSContext.current()) { [data] resolve, reject in
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                reject?.call(withArguments: ["Response is not JSON"])
                return
            }
            
            resolve?.call(withArguments: [json])
        }
    }
    
    func text() -> JSValue {
        .init(newPromiseIn: JSContext.current()) { [data] resolve, reject in
            guard let text = String(data: data, encoding: .utf8) else {
                reject?.call(withArguments: [])
                return
            }
            
            resolve?.call(withArguments: [text])
        }
    }
}
