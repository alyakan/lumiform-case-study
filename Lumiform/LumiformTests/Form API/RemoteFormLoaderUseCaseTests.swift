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

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Result<Data, Error>) -> Void) {
        client.get(from: url) { _ in }
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
        private(set) var requestedURLs: [URL] = []

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
