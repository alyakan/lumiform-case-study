//
//  RemoteFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 24/07/2025.
//

import XCTest
import Lumiform

final class RemoteFormLoader {

    init(client: HTTPClient) {

    }
}

final class RemoteFormLoaderUseCaseTests: XCTest {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFormLoader(client: client)

        XCTAssertEqual(client.requestedURLs, [], "Expected no requests, got: \(client.requestedURLs)")
    }

    // MARK: - Helpers

    final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs: [URL] = []

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
