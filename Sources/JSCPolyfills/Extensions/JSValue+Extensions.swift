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
    
    func invokeAsyncMethod(_ method: String, withArguments arguments: [Any]) async throws -> JSValue {
        guard let promise = invokeMethod(method, withArguments: arguments) else {
            throw JSError(message: "Invalid method")
        }
        
        return try await resolvePromise(promise)
    }
    
    func asyncCall(withArguments arguments: [Any]) async throws -> JSValue {
        guard let promise = call(withArguments: arguments) else {
            throw JSError(message: "Invalid call")
        }
        
        return try await resolvePromise(promise)
    }
    
    private func resolvePromise(_ promise: JSValue) async throws -> JSValue {
        return try await withCheckedThrowingContinuation { continuation in
            let resolveCallback: @convention(block) (JSValue) -> Void = { value in
                continuation.resume(returning: value)
            }
            
            let rejectCallback: @convention(block) (JSValue?) -> Void = { error in
                let wrappedError = JSError(message: error?.invokeMethod("toString", withArguments: [])?.toString() ?? "unknown")
                continuation.resume(throwing: wrappedError)
            }
            
            guard let resolveValue = JSValue(object: resolveCallback, in: context), let rejectValue = JSValue(object: rejectCallback, in: context) else {
                continuation.resume(throwing: JSError(message: "Failed to wrap callbacks into JSValues"))
                return
            }
            
            guard promise.invokeMethod("then", withArguments: [resolveValue, rejectValue])?.isUndefined == false else {
                continuation.resume(throwing: JSError(message: "Failed to invoke 'Promise.then'"))
                return
            }
        }
    }
}
