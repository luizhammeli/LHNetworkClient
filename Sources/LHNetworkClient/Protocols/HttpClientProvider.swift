//
//  HttpClientProvider.swift
//  
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation

public protocol HttpClientProvider {
    var url: URL { get set }
    var baseURL: String? { get }
    var queryParams: [String: String]? { get }
    var headers: [String: String]? { get }
    var body: [String: Any]? { get }
    var method: Method { get }
    var jsonDecoder: JSONDecoder? { get }
}

public extension HttpClientProvider {
    internal func makeBodyData() -> Data? {
        if let body = body, let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) as Data {            
            return bodyData
        }
        return nil
    }
    
    internal func makeURLWithQueryItems() -> URL {
        guard let params = queryParams, params.count > 0 else { return url }

        let queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url ?? self.url
    }
}
