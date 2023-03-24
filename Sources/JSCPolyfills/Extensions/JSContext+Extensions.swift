//
//  JSContext+Extensions.swift
//  
//
//  Created by Alexander Steinhauer on 23.03.23.
//

import Foundation
import JavaScriptCore

extension JSContext {
    func evaluateBlock(_ script: String) -> JSValue? {
        evaluateScript("(() => { \(script) })()")
    }
}
