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
    
    private func register(context: JSContext) {
        let fetch: @convention(block) (JSValue, JSValue?) -> JSValue = { resource, options in
            JSValue(newPromiseIn: context) { resolve, reject in
                Task {
                    let response = await self.fetch(request: self.buildRequest(resource: resource, options: options))
                    
                    
                    guard let response = JSValue(object: response, in: context) else {
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
    
    private func fetch(request: Request) async -> Response? {
        guard let request = request.urlRequest else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return Response(data: data, urlResponse: response)
        } catch {
            return nil
        }
    }
}
