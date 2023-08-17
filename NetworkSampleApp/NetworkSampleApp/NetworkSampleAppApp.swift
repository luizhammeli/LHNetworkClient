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
            let viewModel = ContentViewModel(client: URLSessionHttpClient())
            NavigationView {
                ContentView(viewModel: viewModel)
            }
        }
    }
}
