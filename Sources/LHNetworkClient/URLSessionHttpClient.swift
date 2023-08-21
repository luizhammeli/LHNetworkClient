//
//  URLSessionHttpClient.swift
//
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Combine
import Foundation

public final class URLSessionHttpClient: HTTPClient {
    private var subscription: Set<AnyCancellable> = []
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public func fetch<T: Codable>(provider: HttpClientProvider, completion: @escaping (Result<T, HttpError>) -> Void) {
        var request = URLRequest(url: provider.makeURLWithQueryItems())
        request.httpMethod = provider.method.rawValue
        provider.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        debugPrint("Base URL: \(provider.url)")
        debugPrint("Headers: \(provider.headers ?? [:])")
        debugPrint("Method: \(provider.method.rawValue)")
        debugPrint("Query Items: \(provider.queryParams ?? [:])")
        debugPrint("Complete URL: \(request.url?.description ?? "")")

        request.httpBody = provider.makeBodyData()
        
        urlSession.dataTaskPublisher(for: request)
            .retry(1)
            .tryMap({ [weak self] data, response in
                guard let self = self else { throw HttpError.unknown }
                return try self.mapResponseData(data: data, response: response, decoder: provider.jsonDecoder ?? JSONDecoder()) as T
            })
            .mapError(mapError)            
            .sink { [weak self] result in
                self?.mapCompletion(url: request.url, result: result, completion: completion)
            } receiveValue: { decodedData in
                completion(.success(decodedData))
            }.store(in: &subscription)
    }
    
    private func mapCompletion<T: Codable>(url: URL?, result: Subscribers.Completion<HttpError>, completion: @escaping (Result<T, HttpError>) -> Void) {
        switch result {
        case .finished:
            debugPrint("Finished with Success: \(url?.description ?? "")")
        case .failure(let error):
            debugPrint("Finished with Error for URL: \(url?.description ?? "") Error Code: \(error)")
            completion(.failure(error))
        }
    }
    
    private func mapResponseData<T: Codable>(data: Data, response: URLResponse, decoder: JSONDecoder) throws -> T {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if let error = StatusCodeValidator.checkStatusCode(statusCode: statusCode) {
                debugPrint("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
                debugPrint("Failure Request")
                debugPrint("Request StatusCode: \(statusCode)")
                debugPrint("Request StatusCode Description Error: \(error)")
                throw error
            }
            do {
                debugPrint("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅")
                debugPrint("Success Request")
                debugPrint("Request StatusCode: \(statusCode)")
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    debugPrint("Response Data:")
                    debugPrint(String(decoding: jsonData, as: UTF8.self))
                } else {
                    debugPrint("json data malformed")
                }
                return try decoder.decode(T.self, from: data)
            } catch {
                throw HttpError.invalidData
            }
        }
        
        throw HttpError.invalidRequest
    }
    
    private func mapError(error: Error) -> HttpError {
        switch error {
        case let error as HttpError:
            return error
        case URLError.notConnectedToInternet:
            return .noConnectivity
        default:
            return .unknown
        }
    }
}

