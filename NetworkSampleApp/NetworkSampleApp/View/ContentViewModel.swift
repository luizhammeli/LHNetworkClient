//
//  ContentViewModel.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

@MainActor
protocol ContentViewModelProtocol {
    func fetchEpisodes()
}

@Observable
final class ContentViewModel: ContentViewModelProtocol {
    private(set) var episodes: [Episode] = []
    private(set) var isLoading: Bool = false
    private let service: ContentServiceProtocol
    
    init(service: ContentServiceProtocol) {
        self.service = service
    }

    func fetchEpisodes() {
        isLoading = true
        Task {
            episodes = (try? await service.fetchEpisodes()) ?? []
            isLoading = false
        }
    }
}
