//
//  ConsolePolyfill.swift
//  
//
//  Created by Alexander Steinhauer on 21.03.23.
//

import Foundation
import JavaScriptCore
import OSLog

@objc private protocol ConsolePolyfillExport: JSExport {
    func debug(_ message: JSValue)
    func error(_ message: JSValue)
    func info(_ message: JSValue)
    func log(_ message: JSValue)
    func warn(_ message: JSValue)
}

final class ConsolePolyfill: NSObject, ConsolePolyfillExport {
    static func register(context: JSContext) {
        let polyfill = ConsolePolyfill()
        context.setObject(polyfill, forKeyedSubscript: "console" as NSString)
    }
    
    private let logger: Logger = .init(subsystem: "JavaScriptCore", category: "console")
    
    func log(_ message: JSValue) {
        logger.log("\(message)")
    }
    
    func debug(_ message: JSValue) {
        logger.debug("\(message)")
    }
    
    func info(_ message: JSValue) {
        logger.info("\(message)")
    }
    
    func warn(_ message: JSValue) {
        logger.warning("\(message)")
    }
    
    func error(_ message: JSValue) {
        logger.error("\(message)")
    }
}
