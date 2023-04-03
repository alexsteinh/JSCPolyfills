//
//  JSValue+Extensions.swift
//  
//
//  Created by Alexander Steinhauer on 25.03.23.
//

import Foundation
import JavaScriptCore

public extension JSValue {
    func resolvePromise(then: @escaping (JSValue) -> JSValue?) {
        forProperty("then")?.call(withArguments: [then as @convention(block) (JSValue) -> JSValue?])
    }
    
    func resolvePromise() async -> JSValue {
        await withCheckedContinuation { continuation in
            resolvePromise { resolution in
                continuation.resume(returning: resolution)
                return nil
            }
        }
    }
    
    func invokeAsyncMethod(_ method: String, withArguments arguments: [Any]) async -> Result<JSValue, JSError> {
        guard let promise = invokeMethod(method, withArguments: arguments) else {
            return .failure(.init(message: "Invalid method"))
        }
        
        return await resolvePromise(promise)
    }
    
    func asyncCall(withArguments arguments: [Any]) async -> Result<JSValue, JSError> {
        guard let promise = call(withArguments: arguments) else {
            return .failure(.init(message: "Invalid call"))
        }
        
        return await resolvePromise(promise)
    }
    
    private func resolvePromise(_ promise: JSValue) async -> Result<JSValue, JSError> {
        return await withCheckedContinuation { continuation in
            let resolveCallback: @convention(block) (JSValue) -> Void = { value in
                continuation.resume(returning: .success(value))
            }
            
            let rejectCallback: @convention(block) (JSValue?) -> Void = { error in
                let wrappedError = JSError(message: error?.invokeMethod("toString", withArguments: [])?.toString() ?? "unknown")
                continuation.resume(returning: .failure(wrappedError))
            }
            
            guard let resolveValue = JSValue(object: resolveCallback, in: context), let rejectValue = JSValue(object: rejectCallback, in: context) else {
                continuation.resume(returning: .failure(.init(message: "Failed to wrap callbacks into JSValues")))
                return
            }
            
            guard promise.invokeMethod("then", withArguments: [resolveValue, rejectValue])?.isUndefined == false else {
                continuation.resume(returning: .failure(.init(message: "Failed to invoke 'Promise.then'")))
                return
            }
        }
    }
}
