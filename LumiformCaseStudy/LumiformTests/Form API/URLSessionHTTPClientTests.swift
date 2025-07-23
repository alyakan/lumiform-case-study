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
}
