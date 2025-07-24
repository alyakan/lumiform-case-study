//
//  RemoteFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 24/07/2025.
//

import XCTest
import Lumiform

final class RemoteFormLoader {
    private let url: URL
    private let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Result<Data, Error>) -> Void) {
        client.get(from: url) { result in
            completion(.failure(.connectivity))
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
        let expectedError = RemoteFormLoader.Error.connectivity

        let exp = expectation(description: "Waiting for completion")
        sut.load { result in
            switch result {
            case .success(let receivedData):
                XCTFail("Expected error, got: \(receivedData)")
            case .failure(let receivedError as RemoteFormLoader.Error):
                XCTAssertEqual(receivedError, expectedError)
            }
            exp.fulfill()
        }
        client.complete(with: anyNSError())
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://some-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (RemoteFormLoader, HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteFormLoader(url: url, client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
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
    }
}
