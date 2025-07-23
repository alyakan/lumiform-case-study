//
//  URLSessionHTTPClientTests.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

import XCTest

final class URLSessionHTTPClient {
    typealias Response = (Data, HTTPURLResponse)
    typealias Result = Swift.Result<Response, Error>

    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error {
                return completion(.failure(error))
            }

            if let data, let response = response as? HTTPURLResponse {
                return completion(.success((data, response)))
            }
        }
        dataTask.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request completion")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let error = anyNSError()
        let sut = makeSUT()
        let exp = expectation(description: "Wait for request completion")

        URLProtocolStub.stub(data: nil, response: nil, error: error)

        sut.get(from: anyURL()) { result in
            switch result {
            case .success(let success):
                XCTFail("Expected failure, got: \(success)")
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_deliversDataOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        URLProtocolStub.stub(data: data, response: response, error: nil)
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        sut.get(from: anyURL()) { result in
            switch result {
            case let .success((receivedData, receivedResponse)):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            case .failure(let error):
                XCTFail("Expected success, got: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)

        trackForMemoryLeaks(sut)
        return sut
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private class URLProtocolStub: URLProtocol {

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        class func observeRequests(_ completion: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: completion)
        }

        class func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        class func removeStub() {
            stub = nil
        }

        // MARK: - URLProtocol

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
            stub.requestObserver?(request)
        }

        override func stopLoading() {}
    }
}

func anyURL() -> URL {
    URL(string: "https://some-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "someError", code: 0)
}

func anyData() -> Data {
    Data("some data".utf8)
}
