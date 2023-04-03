//
//  FetchResponse.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

@objc private protocol ResponseExport: JSExport {
    init()
   
    var headers: FetchHeaders { get }
    var ok: Bool { get }
    var status: Int { get }
    var url: String { get }
    
    func arrayBuffer() -> JSValue
    func json() -> JSValue
    func text() -> JSValue
}

public final class FetchResponse: NSObject, ResponseExport {
    let headers: FetchHeaders
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
    
    public init(headers: FetchHeaders, status: Int, url: String, data: Data) {
        self.headers = headers
        self.status = status
        self.url = url
        self.data = data
        
        super.init()
    }
    
    func clone() -> FetchResponse {
        .init(headers: headers.clone(), status: status, url: url, data: data)
    }
    
    func arrayBuffer() -> JSValue {
        .init(newPromiseIn: JSContext.current()) { [data] resolve, reject in
            // TODO: Works for the moment, but needs a cleaner solution.
            let byteArray = data.map(\.description).joined(separator: ",")
            guard let array = JSContext.current().evaluateScript("new Uint8Array([\(byteArray)])") else {
                reject?.call(withArguments: ["Could not encode response into an ArrayBuffer"])
                return
            }
            
            resolve?.call(withArguments: [array])
        }
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
