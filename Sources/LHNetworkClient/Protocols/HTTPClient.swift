//
//  HTTPClient.swift
//  
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

public protocol HTTPClient {
    func fetch<T: Codable>(provider: HttpClientProvider, completion: @escaping (Result<T, HttpError>) -> Void)
    func fetch(provider: HttpClientProvider, completion: @escaping (Result<Data, HttpError>) -> Void)
}
