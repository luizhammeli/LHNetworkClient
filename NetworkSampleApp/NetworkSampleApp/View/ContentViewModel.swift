//
//  ContentViewModel.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

protocol ContentViewModelProtocol {
    func fetchEpisodes()
}

final class ContentViewModel: ObservableObject, ContentViewModelProtocol {
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var isLoading: Bool = false
    private var service: ContentServiceProtocol
    
    init(service: ContentServiceProtocol) {
        self.service = service
    }
    
    func fetchEpisodes() {
        isLoading = true
        
        service.fetchEpisodes { [weak self] episodes in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.episodes = episodes
            }
        }
    }
}
