import XCTest
@testable import LHNetworkClient

final class LHNetworkClientTests: XCTestCase {
    override class func setUp() {
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopIntercepting()
    }
    
    func test_request_shouldSendCorrectRequestData() {
        let sut = URLSessionHttpClient()
        let fakeUrl = makeFakeURL()
        let fakeHeader = ["Key": "test"]

        let exp = expectation(description: #function)
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, fakeUrl)
            XCTAssertEqual(request.httpMethod, Method.GET.rawValue)
            XCTAssertEqual(request.allHTTPHeaderFields, fakeHeader)
            XCTAssertNil(request.httpBody)
            exp.fulfill()
        }
        sut.fetch(provider: FakeProvider(url: fakeUrl, headers: fakeHeader, method: .GET)) { let _: Result<Data, HttpError> = $0 }

        wait(for: [exp], timeout: 10)
    }
    
    func test_request_shouldSendCorrectURLWithQueryParams() {
        let sut = URLSessionHttpClient()        
        let fakeProvider = FakeProvider(url: makeFakeURL(), queryParams: ["id": "1", "testeKey": "testValue"], method: .GET)

        let exp = expectation(description: #function)
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, fakeProvider.makeURLWithQueryItems())
            exp.fulfill()
        }
        sut.fetch(provider: fakeProvider) { let _: Result<Data, HttpError> = $0 }

        wait(for: [exp], timeout: 10)
    }
    
    func test_request_shouldSendCorrectHttpMethod() {
        let sut = URLSessionHttpClient()

        let exp = expectation(description: #function)
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.httpMethod, Method.POST.rawValue)
            exp.fulfill()
        }
        
        sut.fetch(provider: FakeProvider(url: makeFakeURL(), headers: nil, method: .POST)) { let _: Result<Data, HttpError> = $0 }

        wait(for: [exp], timeout: 10)
    }
    
    func test_request_shouldCompleteWithNotFoundError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 404, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.notFound), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithUnauthorizedError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 401, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.unauthorized), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithForbiddenError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 403, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.forbidden), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithBadRequestError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 400, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.badRequest), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithServerError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 500, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.serverError), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithUnknownErrorWithNotDefinedStatusCode() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 600, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.unknown), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
    
    func test_request_shouldCompleteWithUnknownError() {
        assertResult(with: .failure(.unknown), stub: .init(error: NSError(domain: "", code: 0), response: nil, data: nil))
    }
    
    func test_request_shouldCompleteWithInvalidDataError() {
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        assertResult(with: .failure(.invalidData), stub: .init(error: nil, response: fakeResponse, data: Data()))
    }
    
    func test_request_shouldCompleteWithInvalidRequestError() {
        let fakeResponse = URLResponse(url: makeFakeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        assertResult(with: .failure(.invalidRequest), stub: .init(error: nil, response: fakeResponse, data: nil))
    }
   
    func test_request_shouldCompleteWithUnknownErrorWithNoInternetConnect() {
        let error = URLError(URLError.notConnectedToInternet, userInfo: [:])
        assertResult(with: .failure(.noConnectivity), stub: .init(error: error, response: nil, data: nil))
    }

    func test_request_shouldCompleteWithSuccess() {
        let fakeModel = FakeModel(id: 10)
        let fakeData = try? JSONEncoder().encode(fakeModel)
        let fakeResponse = HTTPURLResponse(url: makeFakeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        assertResult(with: .success(fakeModel), stub: .init(error: nil, response: fakeResponse, data: fakeData))
    }
}

private extension LHNetworkClientTests {
    func makeSUT() -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        checkForMemoryLeaks(instance: sut)
        
        return sut
    }
    
    func makeFakeURL() -> URL {
        return URL(string: "https://test.com")!
    }

    func assertResult(with result: Result<FakeModel, HttpError>?, stub: Stub, file: StaticString = #filePath, line: UInt = #line) {
        var receivedResult: Result<FakeModel, HttpError>?
        let sut = makeSUT()
        
        let exp = expectation(description: #function)
        URLProtocolStub.stub(url: makeFakeURL(), response: stub.response, error: stub.error, data: stub.data)
        sut.fetch(provider: FakeProvider(url: makeFakeURL(), method: .GET)) {
            receivedResult = $0
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedResult, result, file: file, line: line)
    }
}
