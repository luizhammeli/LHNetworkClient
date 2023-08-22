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

        client.fetch(provider: ContentProvider(url: url)) { result in
            let result: Result<[Episode], HttpError> = result
            completion((try? result.get()) ?? [])
        }
    }
}
