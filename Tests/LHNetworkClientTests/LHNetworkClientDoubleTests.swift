//
//  LHNetworkClientDoubleTests.swift
//
//
//  Created by Luiz Diniz Hammerli on 09/04/24.
//

import Foundation
import XCTest

@testable import LHNetworkClient

final class LHNetworkClientDoubleTests: XCTestCase {
    func test_request_shouldCompleteWithNotFoundError() {
        let urlSessionSpy = URLSessionSpy()
        let sut = URLSessionHttpClient(urlSession: urlSessionSpy)
    }
}

final class URLSessionSpy: URLSession {
    var receveivedRequests: [URLRequest] = []
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        receveivedRequests.append(request)
        completionHandler(Data(), nil, nil)
        return URLSessionDataTask()
    }
}
