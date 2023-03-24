//
//  JSValue+Extensions.swift
//  
//
//  Created by Alexander Steinhauer on 25.03.23.
//

import Foundation
import JavaScriptCore

extension JSValue {
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
}
