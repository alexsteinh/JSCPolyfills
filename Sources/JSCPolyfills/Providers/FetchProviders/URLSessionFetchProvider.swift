//
//  URLSessionFetchProvider.swift
//  
//
//  Created by Alexander Steinhauer on 26.03.23.
//

import Foundation

final class URLSessionFetchProvider: FetchProvider {
    func fetch(request: FetchRequest) async -> FetchResponse? {
        guard let urlRequest = buildURLRequest(from: request) else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            return buildResponse(fromData: data, response: response)
        } catch {
            return nil
        }
    }
    
    private func buildURLRequest(from request: FetchRequest) -> URLRequest? {
        guard let url = URL(string: request.url) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.allHTTPHeaderFields = request.headers.dict()
        return urlRequest
    }
    
    private func buildResponse(fromData data: Data, response: URLResponse) -> FetchResponse? {
        guard let response = response as? HTTPURLResponse, let url = response.url?.absoluteString else {
            return nil
        }
        
        return FetchResponse(headers: .init(dict: response.allHeaderFields), status: response.statusCode, url: url, data: data)
    }
}
