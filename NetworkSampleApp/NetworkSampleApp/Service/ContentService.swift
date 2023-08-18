//
//  ContentService.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 18/08/23.
//

import Foundation
import LHNetworkClient

protocol ContentServiceProtocol {
    func fetchEpisodes(completion: @escaping ([Episode]) -> Void)
}

final class ContentService: ContentServiceProtocol {
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchEpisodes(completion: @escaping ([Episode]) -> Void) {
        guard let url = URL(string: "\(Enviroment.baseURL)episodes") else { return }
        let headers = ["X-API-TOKEN": "1772bb7bc78941e2b51c9c67d17ee76e"]
        
        client.fetch(url: url, headers: headers, body: nil, method: .GET) { result in
            let result: Result<[Episode], HttpError> = result
            completion((try? result.get()) ?? [])
        }
    }
}
