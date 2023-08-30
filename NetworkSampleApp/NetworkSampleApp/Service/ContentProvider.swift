//
//  ContentProvider.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 21/08/23.
//

import Foundation
import LHNetworkClient

final class ContentProvider: HttpClientProvider {
    var cancelPreviousRequests: Bool = false
    
    var url: URL
    
    var baseURL: String? {
        return Enviroment.baseURL
    }
    
    var queryParams: [String : String]? {
        return nil
    }
    
    var headers: [String : String]? {
        ["X-API-TOKEN": "1772bb7bc78941e2b51c9c67d17ee76e"]
    }
    
    var body: [String : Any]? {
        return nil
    }
    
    var method: LHNetworkClient.Method {
        .GET
    }
    
    var jsonDecoder: JSONDecoder? {
        JSONDecoder()
    }
    
    init(url: URL) {
        self.url = url
    }
}
