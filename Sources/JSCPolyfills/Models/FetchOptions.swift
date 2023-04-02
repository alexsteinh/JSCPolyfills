//
//  FetchOptions.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

public final class FetchOptions {
    public let method: String
    public let headers: FetchHeaders
    
    init(options: JSValue?) {
        let methodValue = options?.forProperty("method")
        if let methodValue, methodValue.isString {
            method = methodValue.toString()
        } else {
            method = "GET"
        }
        
        let headersValue = options?.forProperty("headers")
        if let headersValue, let headers = headersValue.toObjectOf(FetchHeaders.self) as? FetchHeaders {
            self.headers = headers
        } else if let headersValue {
            headers = .init(headers: headersValue)
        } else {
            headers = .empty
        }
    }
    
    public init(method: String, headers: FetchHeaders) {
        self.method = method
        self.headers = headers
    }
}
