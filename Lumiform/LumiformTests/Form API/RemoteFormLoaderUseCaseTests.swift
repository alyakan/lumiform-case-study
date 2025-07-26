//
//  RemoteFormLoaderUseCaseTests.swift
//  LumiformTests
//
//  Created by Aly Yakan on 24/07/2025.
//

import XCTest
import Lumiform

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
        let validFormData = FormItem.simpleSampleData().data

        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: validFormData, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidData = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }

    func test_load_deliversFormOn200HTTPResponseWithSimpleValidJSON() {
        let (sut, client) = makeSUT()
        let dataToReturn = FormItem.simpleSampleData()
        let expectedForm = Form(rootPage: dataToReturn.item)

        expect(sut, toCompleteWith: .success(expectedForm), when: {
            client.complete(withStatusCode: 200, data: dataToReturn.data)
        })
    }

    func test_load_deliversFormOn200HTTPResponseWithRecursiveValidJSON() {
        let (sut, client) = makeSUT()
        let dataToReturn = FormItem.recursiveSampleData()
        let expectedForm = Form(rootPage: dataToReturn.item)

        expect(sut, toCompleteWith: .success(expectedForm), when: {
            client.complete(withStatusCode: 200, data: dataToReturn.data)
        })
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://some-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FormLoader, HTTPClientSpy) {

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
        _ sut: FormLoader,
        toCompleteWith expectedResult: RemoteFormLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let exp = expectation(description: "Waiting for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedForm), .success(expectedForm)):
                XCTAssertEqual(receivedForm, expectedForm, file: file, line: line)
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
}
