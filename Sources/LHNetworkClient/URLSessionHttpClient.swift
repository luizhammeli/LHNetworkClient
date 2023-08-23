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
        let request = makeURLRequest(with: provider)
        
        subscription.forEach { $0.cancel() }
        
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
    
    private func mapResponseData<T: Codable>(data: Data, response: URLResponse, decoder: JSONDecoder) throws -> T {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if let error = StatusCodeValidator.checkStatusCode(statusCode: statusCode) {
                self.lastReceivedStatusCode = statusCode
                logger.logFailureRequest(error: error, statusCode: statusCode)
                throw error
            }
            do {
                logger.logSuccessRequest(data: data, statusCode: statusCode)
                let decodedData = try decoder.decode(T.self, from: data)                
                return decodedData
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
