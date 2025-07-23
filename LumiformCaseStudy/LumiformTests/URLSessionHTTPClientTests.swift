//
//  URLSessionHTTPClientTests.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) { _, _, _ in }
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

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return URLSessionHTTPClient(session: session)
    }

    private class URLProtocolStub: URLProtocol {

        private struct Stub {
            let requestObserver: ((URLRequest) -> Void)?
        }

        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }

        class func observeRequests(_ completion: @escaping (URLRequest) -> Void) {
            stub = Stub(requestObserver: completion)
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

            client?.urlProtocolDidFinishLoading(self)
            stub.requestObserver?(request)
        }

        override func stopLoading() {}
    }
}

func anyURL() -> URL {
    URL(string: "https://some-url.com")!
}
