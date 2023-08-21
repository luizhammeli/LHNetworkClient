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
    
    public func fetch<T: Codable>(url: URL, headers: [String: String]?, body: [String: Any]?, method: Method, completion: @escaping (Result<T, HttpError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        debugPrint("URL: \(url)")
        debugPrint("Headers: \(headers ?? [:])")
        debugPrint("Method: \(method.rawValue)")
        
        if let body = body, let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) as Data, method != .GET {
            debugPrint("Body: \(body)")
            request.httpBody = bodyData
        }
        
        urlSession.dataTaskPublisher(for: request)
            .retry(1)
            .tryMap({ [weak self] data, response in
                guard let self = self else { throw HttpError.unknown }
                return try self.mapResponseData(data: data, response: response) as T
            })
            .mapError(mapError)            
            .sink { [weak self] result in
                self?.mapCompletion(url: url, result: result, completion: completion)
            } receiveValue: { decodedData in
                completion(.success(decodedData))
            }.store(in: &subscription)
    }
    
    private func mapCompletion<T: Codable>(url: URL, result: Subscribers.Completion<HttpError>, completion: @escaping (Result<T, HttpError>) -> Void) {
        switch result {
        case .finished:
            debugPrint("Finished with Success: \(url)")
        case .failure(let error):
            debugPrint("Finished with Error for URL: \(url) Error Code: \(error)")
            completion(.failure(error))
        }
    }
    
    private func mapResponseData<T: Codable>(data: Data, response: URLResponse) throws -> T {
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if let error = StatusCodeValidator.checkStatusCode(statusCode: statusCode) {
                debugPrint("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌")
                debugPrint("Failure Request:")
                debugPrint("Request StatusCode: \(statusCode)")
                debugPrint("Request StatusCode Description Error: \(error)")
                throw error
            }
            do {
                debugPrint("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅")
                debugPrint("Success Request:")
                debugPrint("Request StatusCode: \(statusCode)")
                debugPrint("Response Data: \(String(data: data, encoding: .utf8) ?? "")")
                return try JSONDecoder().decode(T.self, from: data)
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

