//
//  FetchRequest.swift
//  
//
//  Created by Alexander Steinhauer on 24.03.23.
//

import Foundation
import JavaScriptCore

@objc private protocol RequestExport: JSExport {
    init(input: JSValue, options: JSValue?)
   
    var headers: FetchHeaders { get }
    var method: String { get }
    var url: String { get }
}

public final class FetchRequest: NSObject, RequestExport {
    public let input: String
    public let options: FetchOptions
    
    var headers: FetchHeaders {
        options.headers
    }
    
    var method: String {
        options.method
    }
    
    var url: String {
        input
    }
    
    init(input: JSValue, options: JSValue?) {
        if let request = input.toObjectOf(FetchRequest.self) as? FetchRequest {
            self.input = request.input
            self.options = request.options
        } else {
            self.input = input.toString() ?? ""
            self.options = FetchOptions(options: options)
        }
        
        super.init()
    }
    
    public init(input: String, options: FetchOptions) {
        self.input = input
        self.options = options
    }
}
