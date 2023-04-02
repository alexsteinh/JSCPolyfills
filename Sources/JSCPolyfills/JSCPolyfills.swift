//
//  JSCPolyfills.swift
//
//
//  Created by Alexander Steinhauer on 21.03.23.
//

import Foundation
import JavaScriptCore

public final class JSCPolyfills {
    private var fetchPolyfill: FetchPolyfill
    
    public init() {
        fetchPolyfill = .init(fetchProvider: URLSessionFetchProvider())
    }
    
    public func setFetchPolyfill(_ fetchPolyfill: FetchPolyfill) -> Self {
        self.fetchPolyfill = fetchPolyfill
        return self
    }
    
    public func createJSContext(for virtualMachine: JSVirtualMachine) -> JSContext? {
        guard let context = JSContext(virtualMachine: virtualMachine) else {
            return nil
        }
        
        ConsolePolyfill.register(context: context)
        TimerPolyfill.register(context: context)
        fetchPolyfill.register(context: context)
        return context
    }
}
