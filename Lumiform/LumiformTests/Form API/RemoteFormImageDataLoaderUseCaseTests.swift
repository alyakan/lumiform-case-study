//
//  RemoteFormImageDataLoaderUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

protocol FormImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}

final class RemoteFormImageDataLoader: FormImageDataLoader {
    private let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity, invalidResponse, invalidData
    }

    init(client: HTTPClient) {
        self.client = client
    }

    func loadImageData(from url: URL, completion: @escaping (FormImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                completion(.failure(Error.invalidResponse))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

class RemoteFormImageDataLoaderUseCaseTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }

    func test_loadImageDataFromURL_deliversInvalidResponseErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500].enumerated()

        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidResponse), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FormImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFormImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

    private func expect(
        _ sut: FormImageDataLoader,
        toCompleteWith expectedResult: FormImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let url = anyURL()
        let exp = expectation(description: "wait for completion")

        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteFormImageDataLoader.Error) -> FormImageDataLoader.Result {
        .failure(error)
    }
}
