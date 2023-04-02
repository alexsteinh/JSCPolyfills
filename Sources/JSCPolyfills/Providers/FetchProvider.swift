//
//  FetchProvider.swift
//  
//
//  Created by Alexander Steinhauer on 26.03.23.
//

import Foundation

public protocol FetchProvider {
    func fetch(request: FetchRequest) async -> FetchResponse?
}
