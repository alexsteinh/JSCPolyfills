//
//  TimerPolyfill.swift
//  
//
//  Created by Alexander Steinhauer on 21.03.23.
//

import Foundation
import JavaScriptCore

final class TimerPolyfill: NSObject {
    static func register(context: JSContext) {
        let polyfill = TimerPolyfill()
        polyfill.register(context: context)
    }
    
    private var timers: [String: Timer] = .init()
    
    private func register(context: JSContext) {
        let clearTimer: @convention(block) (String) -> Void = { id in
            self.removeTimer(id: id)
        }
        
        let setInterval: @convention(block) (JSValue, Double) -> String = { callback, milliseconds in
            return self.createTimer(callback: callback, milliseconds: milliseconds, repeats: true)
        }
        
        let setTimeout: @convention(block) (JSValue, Double) -> String = { callback, milliseconds in
            return self.createTimer(callback: callback, milliseconds: milliseconds, repeats: false)
        }
        
        context.setObject(clearTimer, forKeyedSubscript: "clearInterval" as NSString)
        context.setObject(clearTimer, forKeyedSubscript: "clearTimeout" as NSString)
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
    }
    
    private func removeTimer(id: String) {
        timers.removeValue(forKey: id)?.invalidate()
    }
    
    private func createTimer(callback: JSValue, milliseconds: Double, repeats: Bool) -> String {
        let id = UUID().uuidString
        
        DispatchQueue.main.async {
            let timer = Timer.scheduledTimer(withTimeInterval: milliseconds / 1000, repeats: repeats) { [weak self] _ in
                callback.call(withArguments: [])
                if !repeats {
                    self?.removeTimer(id: id)
                }
            }
            
            self.timers[id] = timer
        }
        
        return id
    }
}
