//
//  RemoteFormImageDataLoaderUseCaseTests.swift
//  Lumiform
//
//  Created by Aly Yakan on 28/07/2025.
//

import XCTest
import Lumiform

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

    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT(dataValidator: { _ in return false })
        let emptyData = Data()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }

    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }

    func test_loadImageDataFromURL_doesNotDeliveResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFormImageDataLoader? = RemoteFormImageDataLoader(client: client, dataValidator: { _ in return true})

        var capturedResults = [FormImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL(), completion: { capturedResults.append($0) })

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        dataValidator: @escaping (Data) -> Bool = { _ in true },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FormImageDataLoader, client: HTTPClientSpy) {

        let client = HTTPClientSpy()
        let sut = RemoteFormImageDataLoader(client: client, dataValidator: dataValidator)
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
