//
//  ContentViewModel.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation
import LHNetworkClient

struct Enviroment {
    static let baseURL: String = "https://cocoacasts-mock-api.herokuapp.com/api/v1/"
}

final class ContentViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var isLoading: Bool = false
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchEpisodes() {
        guard let url = URL(string: "\(Enviroment.baseURL)episodes") else { return }
        let headers = ["X-API-TOKEN": "1772bb7bc78941e2b51c9c67d17ee76e"]
        
        isLoading = true
        
        client.fetch(url: url, headers: headers, body: nil, method: .GET) { [weak self] result in
            DispatchQueue.main.async {
                let result: Result<[Episode], HttpError> = result
                self?.isLoading = false
                self?.episodes = (try? result.get()) ?? []
            }
        }
    }
}

struct Episode: Codable {
    let title: String
    let id: Int
    let excerpt: String
    let imageURL: String
}
