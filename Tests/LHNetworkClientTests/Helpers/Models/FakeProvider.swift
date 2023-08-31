//
//  FakeProvider.swift
//  
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation
@testable import LHNetworkClient

struct FakeProvider: HttpClientProvider {
    var cancelPreviousRequests: Bool = true
    var url: URL
    var baseURL: String?
    var queryParams: [String : String]?
    var headers: [String : String]?
    var body: [String : Any]?
    var method: LHNetworkClient.Method
    var jsonDecoder: JSONDecoder?
    
    init(url: URL,
         baseURL: String? = nil,
         queryParams: [String : String]? = nil,
         headers: [String : String]? = nil,
         body: [String : Any]? = nil,
         method: LHNetworkClient.Method,
         jsonDecoder: JSONDecoder? = JSONDecoder()) {
        self.url = url
        self.baseURL = baseURL
        self.queryParams = queryParams
        self.headers = headers
        self.body = body
        self.method = method
        self.jsonDecoder = jsonDecoder
    }
}
