//
//  ContentView.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.episodes, id: \.id) { episode in
                    Text(episode.title)
                }
            }
        }
        .onAppear {
            viewModel.fetchEpisodes()
        }
        .navigationTitle("Episodes")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ContentViewModel(service: PreviewServide())
        ContentView(viewModel: viewModel)
    }
    
    struct PreviewServide: ContentServiceProtocol {
        func fetchEpisodes(completion: @escaping ([Episode]) -> Void) {
            completion([.init(title: "Teste 1", id: 0, excerpt: "", imageURL: ""),
                        .init(title: "Teste 2", id: 0, excerpt: "", imageURL: "")])
        }
    }
}

