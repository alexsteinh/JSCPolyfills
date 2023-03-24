//
//  FetchPolyfill.swift
//  
//
//  Created by Alexander Steinhauer on 22.03.23.
//

import Foundation
import JavaScriptCore

final class FetchPolyfill {
    static func register(context: JSContext) {
        let polyfill = FetchPolyfill()
        polyfill.register(context: context)
    }
    
    private let fetchProvider: FetchProvider = URLSessionFetchProvider()
    
    private func register(context: JSContext) {
        let fetch: @convention(block) (JSValue, JSValue?) -> JSValue = { resource, options in
            JSValue(newPromiseIn: context) { resolve, reject in
                Task {
                    let request = self.buildRequest(resource: resource, options: options)
                    guard let response = await self.fetchProvider.fetch(request: request) else {
                        reject?.call(withArguments: [])
                        return
                    }
                    
                    guard let response = JSValue(object: response, in: context) else {
                        reject?.call(withArguments: [])
                        return
                    }
                    
                    resolve?.call(withArguments: [response])
                }
            }
        }
        
        context.setObject(fetch, forKeyedSubscript: "fetch" as NSString)
        
        context.setObject(Headers.self, forKeyedSubscript: "Headers" as NSString)
        context.setObject(Request.self, forKeyedSubscript: "Request" as NSString)
        context.setObject(Response.self, forKeyedSubscript: "Response" as NSString)
    }
    
    private func buildRequest(resource: JSValue, options: JSValue?) -> Request {
        if let request = resource.toObjectOf(Request.self) as? Request {
            return request
        }
        
        return Request(input: resource, options: options)
    }
}
