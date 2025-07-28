//
//  RemoteFormImageDataLoaderUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

protocol FormImageDataLoader {}

final class RemoteFormImageDataLoader: FormImageDataLoader {
    init(client: HTTPClient) {}
}

class RemoteFormImageDataLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FormImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFormImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
}
