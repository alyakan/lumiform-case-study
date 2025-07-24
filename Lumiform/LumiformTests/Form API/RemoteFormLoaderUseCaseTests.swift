//
//  RemoteFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 24/07/2025.
//

import XCTest
import Lumiform

final class RemoteFormLoader {
    typealias Result = Swift.Result<Data, Swift.Error>

    private let url: URL
    private let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity, invalidData
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

final class RemoteFormLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.requestedURLs, [], "Expected no requests, got: \(client.requestedURLs)")
    }

    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.load() { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }

    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500].enumerated()

        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([:])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://some-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (RemoteFormLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteFormLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteFormLoader.Error) -> RemoteFormLoader.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteFormLoader,
        toCompleteWith expectedResult: RemoteFormLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let exp = expectation(description: "Waiting for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as RemoteFormLoader.Error), .failure(expectedError as RemoteFormLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 0.1)
    }

    private func makeItemsJSON(_ items: [String: Any]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

    final class HTTPClientSpy: HTTPClient {
        private var receivedMessages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []

        var requestedURLs: [URL] {
            receivedMessages.map(\.url)
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedMessages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            receivedMessages[index].completion(.failure(error))
        }

        func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: receivedMessages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!

            receivedMessages[index].completion(.success((data, response)))
        }
    }
}
