//
//  HTTPClient.swift
//  
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation

public protocol HTTPClient {
    func fetch<T: Codable>(url: URL, headers: [String: String]?, body: [String: Any]?, method: Method, completion: @escaping (Result<T, HttpError>) -> Void)
}
