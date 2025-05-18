//
//  ContentService.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 18/08/23.
//

import Foundation
import LHNetworkClient

protocol ContentServiceProtocol {
    func fetchEpisodes() async throws -> [Episode]
}

final class ContentService: ContentServiceProtocol {
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }

    func fetchEpisodes() async throws -> [Episode] {
        guard let url = URL(string: "\(Enviroment.baseURL)episodes") else { throw NSError() }

        let value: [Episode] = try await client.fetch(provider: ContentProvider(url: url))
        return value
    }
}
