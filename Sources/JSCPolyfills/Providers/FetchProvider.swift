//
//  FetchProvider.swift
//  
//
//  Created by Alexander Steinhauer on 26.03.23.
//

import Foundation

protocol FetchProvider {
    func fetch(request: Request) async -> Response?
}
