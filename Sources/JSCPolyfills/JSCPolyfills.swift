//
//  JSCPolyfills.swift
//
//
//  Created by Alexander Steinhauer on 21.03.23.
//

import JavaScriptCore

public class JSCPolyfills {
    private init() {}
    
    public static func createJSContext(for virtualMaschine: JSVirtualMachine) -> JSContext? {
        guard let context = JSContext(virtualMachine: virtualMaschine) else {
            return nil
        }
        
        ConsolePolyfill.register(context: context)
        TimerPolyfill.register(context: context)
        return context
    }
}
