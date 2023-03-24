//
//  Request.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

@objc private protocol RequestExport: JSExport {
    init(input: JSValue, options: JSValue?)
   
    var headers: Headers { get }
    var method: String { get }
    var url: String { get }
}

final class Request: NSObject, RequestExport {
    let input: String
    let options: FetchOptionsProxy
    
    var headers: Headers {
        options.headers
    }
    
    var method: String {
        options.method
    }
    
    var url: String {
        input
    }
    
    init(input: JSValue, options: JSValue?) {
        if let request = input.toObjectOf(Request.self) as? Request {
            self.input = request.input
            self.options = request.options
        } else {
            self.input = input.toString() ?? ""
            self.options = FetchOptionsProxy(options: options)
        }
        
        super.init()
    }
    
    init(input: String, options: FetchOptionsProxy) {
        self.input = input
        self.options = options
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = options.method
        urlRequest.allHTTPHeaderFields = options.headers.dict()
        return urlRequest
    }
}
