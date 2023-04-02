//
//  FetchPolyfill.swift
//  
//
//  Created by Alexander Steinhauer on 22.03.23.
//

import Foundation
import JavaScriptCore

public final class FetchPolyfill {
    private let fetchProvider: FetchProvider
    
    public init(fetchProvider: FetchProvider) {
        self.fetchProvider = fetchProvider
    }
    
    func register(context: JSContext) {
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
        context.setObject(FetchHeaders.self, forKeyedSubscript: "Headers" as NSString)
        context.setObject(FetchRequest.self, forKeyedSubscript: "Request" as NSString)
        context.setObject(FetchResponse.self, forKeyedSubscript: "Response" as NSString)
    }
    
    private func buildRequest(resource: JSValue, options: JSValue?) -> FetchRequest {
        if let request = resource.toObjectOf(FetchRequest.self) as? FetchRequest {
            return request
        }
        
        return FetchRequest(input: resource, options: options)
    }
}
