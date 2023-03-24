//
//  FetchOptionsProxy.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

final class FetchOptionsProxy {
    let method: String
    let headers: Headers
    
    init(options: JSValue?) {
        method = options?.forProperty("method")?.toString() ?? "GET"
        if let headers = options?.forProperty("headers")?.toObjectOf(Headers.self) as? Headers {
            self.headers = headers
        } else {
            headers = options?.forProperty("headers").flatMap { .init(headers: $0) } ?? .empty
        }
    }
    
    init(method: String, headers: Headers) {
        self.method = method
        self.headers = headers
    }
}
