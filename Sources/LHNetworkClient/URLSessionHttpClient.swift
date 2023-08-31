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
    private var lastReceivedStatusCode: Int?
    var logger: NetworkLogger = DefaultNetworkLogger()
    
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public func fetch<T: Codable>(provider: HttpClientProvider, completion: @escaping (Result<T, HttpError>) -> Void) {
        fetch(provider: provider) { result in
            switch result {
            case .success(let data):
                if let decodedData = try? provider.jsonDecoder?.decode(T.self, from: data) {
                    completion(.success(decodedData))
                } else {
                    completion(.failure(HttpError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func fetch(provider: HttpClientProvider, completion: @escaping (Result<Data, HttpError>) -> Void) {
        let request = makeURLRequest(with: provider)
        
        if provider.cancelPreviousRequests {
            subscription.forEach { $0.cancel() }
        }
        
        urlSession.dataTaskPublisher(for: request)
            .retry(1)
            .tryMap { [weak self] data, response in
                guard let self = self else { throw HttpError.unknown }
                if let error = self.checkStatusCode(response: response, data: data) { throw error }
                return data
            }
            .mapError(mapError)
            .sink { [weak self] result in
                self?.mapCompletion(url: request.url, result: result, completion: completion)
            } receiveValue: { data in
                completion(.success(data))
            }.store(in: &subscription)
    }
    
    
    private func makeURLRequest(with provider: HttpClientProvider) -> URLRequest {
        var request = URLRequest(url: provider.makeURLWithQueryItems())
        request.httpMethod = provider.method.rawValue
        provider.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        logger.logRequest(provider: provider)

        request.httpBody = provider.makeBodyData()

        return request
    }
    
    private func mapCompletion<T: Codable>(url: URL?, result: Subscribers.Completion<HttpError>, completion: @escaping (Result<T, HttpError>) -> Void) {
        switch result {
        case .finished:
            lastReceivedStatusCode = nil
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private func checkStatusCode(response: URLResponse, data: Data) -> HttpError? {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if let error = StatusCodeValidator.getDescription(with: statusCode) {
                logger.logFailureRequest(error: error, statusCode: statusCode)
                return error
            } else {
                logger.logSuccessRequest(data: data, statusCode: statusCode)
                return nil
            }
        }
        
        return HttpError.invalidRequest
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
