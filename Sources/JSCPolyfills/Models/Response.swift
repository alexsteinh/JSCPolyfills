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
    
    func text() -> JSValue
}

final class Response: NSObject, ResponseExport {
    let headers: Headers
    let status: Int
    let url: String
    private let _text: String
    
    var ok: Bool {
        200...299 ~= status
    }
    
    override init() {
        headers = .init(dict: [:])
        status = 200
        url = ""
        _text = ""
        
        super.init()
    }
    
    init(headers: Headers, status: Int, url: String, text: String) {
        self.headers = headers
        self.status = status
        self.url = url
        self._text = text
        
        super.init()
    }
    
    convenience init?(data: Data, urlResponse response: URLResponse) {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        self.init(headers: .init(dict: response.allHeaderFields), status: response.statusCode, url: response.url?.absoluteString ?? "", text: text)
    }
    
    func clone() -> Response {
        .init(headers: headers.clone(), status: status, url: url, text: _text)
    }
    
    func text() -> JSValue {
        .init(newPromiseIn: JSContext.current()) { [text = _text] resolve, _ in
            resolve?.call(withArguments: [text])
        }
    }
}
