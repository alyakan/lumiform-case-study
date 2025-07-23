//
//  URLSessionHTTPClientTests.swift
//  LumiformCaseStudy
//
//  Created by Aly Yakan on 23/07/2025.
//

import XCTest
import Lumiform

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

        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as NSError?

        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }

    func test_getFromURL_deliversDataOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let resultValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(data, resultValues?.data)
        XCTAssertEqual(response.url, resultValues?.response.url)
        XCTAssertEqual(response.statusCode, resultValues?.response.statusCode)
    }

    func test_getFromURL_deliversEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let resultValues = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(emptyData, resultValues?.data)
        XCTAssertEqual(response.url, resultValues?.response.url)
        XCTAssertEqual(response.statusCode, resultValues?.response.statusCode)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)

        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> (data: Data, response: HTTPURLResponse)?
    {
        let result = resultFor(data: data, response: response, error: error)
        switch resultFor(data: data, response: response, error: error) {
        case let .success((receivedData, receivedResponse)):
            return (receivedData, receivedResponse)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
        }
        return nil
    }

    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> Error?
    {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .failure(error): return error
        default: XCTFail("Expected failure, got \(result) instead", file: file, line: line)
        }
        return nil
    }

    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line) -> HTTPClient.Result
    {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClient.Result!
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedResult
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

        class func stub(data: Data?, response: URLResponse?, error: Error?) {
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
