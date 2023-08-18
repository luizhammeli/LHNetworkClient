//
//  NetworkSampleAppApp.swift
//  NetworkSampleApp
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import SwiftUI
import LHNetworkClient

@main
struct NetworkSampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            makeContentView()
        }
    }
    
    private func makeContentView() -> some View {
        let service = ContentService(client: URLSessionHttpClient())
        let viewModel = ContentViewModel(service: service)
        return NavigationView {
            ContentView(viewModel: viewModel)
        }
    }
}
